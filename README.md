# Bike Orchestration Scripts

This exists because I didn't want to figure out how to do all of this the
AWS-way.

The 'pull.sh' script should be run at frequent intervals to poll for new
images.

The following environment variables must be defined system-wide:

    ECS_DOCKER_REPO     The URL to the ECS image repository
    OBS_API_SECRET      The Oslo Bysykkel API-key
    PUSHOVER_TOKEN      Token to Pushover
    PUSHOER_USER        User in Pushover

_(Note to me in the future: I put this in ~/.bash_profile on my machine.)_
