# Authorizer

A serverless (AWS lambda) FastAPI authorizer microservice intended to be used with lambda api gateways to authenticate and pass authorization data to microservices.

# Requirements

This project requires installed on your OS.

- docker and docker-compose
- makefile command
- terraform (version 1.1.1)
- git bash (if running on windows)

# Running locally

To start the project run the command:

`make run`

This will build a lambda compatible docker container running fast api that can be accessed via:

`http://localhost:8888`


# Deploying to AWS

Deployment is done when we merge a branch into main on github and the following is orchestrated through the .circleci/config.yml. Before the pipeline will work we require some inital pipeline setup.

Before running any of the below add AWS credentials via terraform ENV Vars:

export TF_VAR_aws_access_key=""
export TF_VAR_aws_secret_key=""

These will also need to be added to our circleci pipeline for the automated pipeline to work correctly.

An S3 bucket to hold the terraform state is needed before commands work create the S3 bucket that matches the s3 bucket in infra/tf_pipeline/main.tf:

`jwnwilson-authorizer`

### Create pipeline

First we need to create infra for pipeline and to push a docker image, from the infra/ folder run: 

`AWS_DEFAULT_REGION=eu-west-1 environment=staging make init_pipeline`
`AWS_DEFAULT_REGION=eu-west-1 environment=staging make apply_pipeline`

This is will create our ECR repo we need to push an image to, the automated pipeline should work from this point on.

## Build image

From the root repo directory run:

`AWS_DEFAULT_REGION=eu-west-1 environment=staging make build push`

This will build an image, tag it and push it to the ECR repository. This will use the aws credentials created by aws CLI stored in ~/.aws/credentials. 

## Deploying image

Get the docker tag from the previous build push command, then inside infra/ folder run:

`AWS_DEFAULT_REGION=eu-west-1 environment=staging make init`
`AWS_DEFAULT_REGION=eu-west-1 environment=staging docker_tag=<docker_tag> make plan`
`AWS_DEFAULT_REGION=eu-west-1 environment=staging docker_tag=<docker_tag> make apply`

This will prepare and build a staging environment for this project, to destroy the environment run:

`AWS_DEFAULT_REGION=eu-west-1 environment=staging make destroy`

To create a different environment run:

`AWS_DEFAULT_REGION=eu-west-1 environment=test make init`
`AWS_DEFAULT_REGION=eu-west-1 environment=test docker_tag=<docker_tag> make plan`
`AWS_DEFAULT_REGION=eu-west-1 environment=test docker_tag=<docker_tag> make apply`

# Domain Driven Development

The structure of this project is based on a DDD programming technique "Hexagonal architecture" as described here:
https://medium.com/ssense-tech/hexagonal-architecture-there-are-always-two-sides-to-every-story-bc0780ed7d9c

The goal is to avoid coupling logic so that it can be re-used across projects.

# To Do

- Automate DB migrations with alembic on lamdba in circle