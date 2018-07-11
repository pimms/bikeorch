#!/bin/bash

SD="$( cd "$(dirname "$0")" ; pwd -P )"

check_app() {
    IMG_NAME=$1
    docker ps | grep "$ECS_DOCKER_REPO/$IMG_NAME" 2>&1 > /dev/null
    app_ok=$?
}

BAD_APPS=()

check_app bikeapi
if [ $app_ok -ne 0 ]; then
    BAD_APPS+=('bikeapi')
fi

check_app bikeweb
if [ $app_ok -ne 0 ]; then
    BAD_APPS+=('bikeweb')
fi

check_app bikeproxy
if [ $app_ok -ne 0 ]; then
    BAD_APPS+=('bikeproxy')
fi

check_app opentsdb
if [ $app_ok -ne 0 ]; then
    BAD_APPS+=('opentsdb')
fi

if [ ${#BAD_APPS[@]} -ne 0 ]; then
    echo BAD APPS: ${BAD_APPS[@]}
    TITLE="Bike Alert!"
    MESSAGE="The following apps are down:"
    for app in ${BAD_APPS[@]}; do
        MESSAGE+=$'\n - '
        MESSAGE+="$app"
    done
    $SD/send_notif.sh "$TITLE" "$MESSAGE"
fi
