#! /bin/bash

set -e
set -x

# Use last commit datetime as git tag
export docker_tag=$(git log -n1 --pretty='format:%cd' --date=format:'%Y%m%d%H%M%S')
