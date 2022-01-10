#! /bin/bash

set -e
set -x

source $(dirname "$0")/util.sh

# Deploy image to lambda
cd infra
docker_tag=${docker_tag} make init
docker_tag=${docker_tag} make plan