#! /bin/bash

set -e
set -x

# Docker login
aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${aws_ecr}
