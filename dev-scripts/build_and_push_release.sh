#!/bin/bash

# Exit early if any command fails
set -e

# Print all commands
set -x 

pwd

CAPROVER_VERSION_FROM_TAG=$1
IMAGE_NAME=caprover/caprover

if [ ! -f ./package-lock.json ]; then
    echo "package-lock.json not found!"
    exit 1;
fi

if ! [ $(id -u) = 0 ]; then
   echo "Must run as sudo or root"
   exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" != "release" ]]; then
    echo 'Not on release branch! Aborting script!';
    exit 1;
fi


git clean -fdx .
npm ci
npm run build

node ./dev-scripts/validate-build-version-docker-hub.js
# Get version from constant file
# Get version from tag (CAPROVER_VERSION_FROM_TAG) env var
# Make sure the two are the same
# Run API request to DockerHub and make sure it's a new version

docker build -t $IMAGE_NAME:$CAPROVER_VERSION_FROM_TAG -t $IMAGE_NAME:latest -f dockerfile-captain.release .
docker push  $IMAGE_NAME:$CAPROVER_VERSION_FROM_TAG
docker push  $IMAGE_NAME:latest
