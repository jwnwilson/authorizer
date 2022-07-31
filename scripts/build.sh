#! /bin/bash

set -e

source $(dirname "$0")/code-artifact-poetry.sh

DOCKER_COMMAND="docker-compose -f docker-compose.yml"

${DOCKER_COMMAND} build --build-arg INSTALL_DEV=true \
	--build-arg CODEARTIFACT_REPOSITORY_URL=${CODEARTIFACT_REPOSITORY_URL} \
	--build-arg CODEARTIFACT_AUTH_TOKEN=${CODEARTIFACT_AUTH_TOKEN}