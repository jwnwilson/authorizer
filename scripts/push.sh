#! /bin/bash

set -e
set -x

region="eu-west-1"
aws_ecr="675468650888.dkr.ecr.eu-west-1.amazonaws.com"
ecr_repo_name="authorizer"
latest_image=`docker images -q authorizer`
# Use last commit datetime as git tag
docker_tag=$(git log -n1 --pretty='format:%cd' --date=format:'%Y%m%d%H%M%S')

# Docker login
source ./scripts/docker.sh

# tag and push docker image
docker tag "${latest_image}" "${aws_ecr}/${ecr_repo_name}:latest"
docker tag "${latest_image}" "${aws_ecr}/${ecr_repo_name}:${docker_tag}"
docker push "${aws_ecr}/${ecr_repo_name}:latest"
docker push "${aws_ecr}/${ecr_repo_name}:${docker_tag}"
