#!/bin/bash

TITLE=$1
MESSAGE=$2

if [ -z "$PUSHOVER_TOKEN" ]; then
    echo 'ERROR: Variable "PUSHOVER_TOKEN" is undefined.'
    exit 1
fi

if [ -z "$PUSHOVER_USER" ]; then
    echo 'ERROR: Variable "PUSHOVER_USER" is undefined.'
    exit 1
fi

curl -G -X POST "https://api.pushover.net/1/messages.json" \
    --data-urlencode "token=$PUSHOVER_TOKEN" \
    --data-urlencode "user=$PUSHOVER_USER" \
    --data-urlencode "message=$MESSAGE" \
    --data-urlencode "title=$TITLE"
