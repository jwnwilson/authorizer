DOCKER_NAME=authorizer
DOCKER_COMMAND=docker-compose -f docker-compose.yml

upgrade_db_local:
	poetry run "alembic upgrade head"

migrate_db:
	${DOCKER_COMMAND} run authorizer bash -c "alembic revision --autogenerate -m \"DB migration\""

upgrade_db:
	${DOCKER_COMMAND} run authorizer bash -c "alembic upgrade head"

build:
	${DOCKER_COMMAND} build --build-arg INSTALL_DEV=true

# push last build image to ECR
push:
	bash ./scripts/push.sh

run:
	${DOCKER_COMMAND} up

stop:
	${DOCKER_COMMAND} down

test:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "pytest app"

lint:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "scripts/lint.sh"

static:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "scripts/lint.sh --check"

# Requires "make init_pipeline apply_pipeline" to be run in infra/ first
deploy:
	bash ./scripts/deploy.sh

clean:
	rm **/**/*.pyc
	rm **/**/__pycache__