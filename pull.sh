#!/bin/bash

if [ -z "$ECS_DOCKER_REPO" ];
then
    echo Variable 'ECS_DOCKER_REPO' must be defined.
    exit 1
fi

SD="$( cd "$(dirname "$0")" ; pwd -P )"

log_in() {
    echo "Logging in"
    eval $(aws ecr get-login | sed 's/-e none //')

    if [ $? -ne 0 ]; then
        echo "Failed to acquire AWS login"
        exit 1
    fi
}

send_notif() {
    IMG_NAME=$1
    $SD/send_notif.sh "Deploy: $IMG_NAME" "A new deployment of $IMG_NAME has been made."
}

clean_images() {
    echo "Cleaning old images"
    docker rmi $(docker images | grep "<none>" | awk '{print $3}')
}

pull_latest() {
    IMG_NAME=$1
    LOCAL_PORT=$2
    IMG_PORT=$3
    EXTRA_ARGS=($@)

    echo "Pulling latest image: $IMG_NAME"
    docker pull $ECS_DOCKER_REPO/$IMG_NAME:latest > $SD/dockerlog

    cat $SD/dockerlog | grep "Downloaded newer image"
    if [ $? -eq 0 ];
    then
        echo "Pull succeeded: $IMG_NAME"
        docker ps | grep "$IMG_NAME"
        if [ $? -eq 0 ]; then
            echo "Image already running, stopping..."
            docker stop $IMG_NAME || exit 1
            docker rm $IMG_NAME || exit 1
        fi

        docker run "--name=$IMG_NAME" -d -p "$LOCAL_PORT:$IMG_PORT" ${EXTRA_ARGS[@]:3} "$ECS_DOCKER_REPO/$IMG_NAME" || exit 1
        send_notif $IMG_NAME

        echo "Started new instance of image: $IMG_NAME"
    else
        echo "No new changes, exiting"
    fi
}

log_in
pull_latest bikeproxy 80 80 --net="host"
pull_latest bikeapi 2001 2001 -e "OBS_API_SECRET=$OBS_API_SECRET" -e "TSDB_URL=http://biketsdb.stienjoa.kim:4242"
pull_latest bikeweb 2002 2002

