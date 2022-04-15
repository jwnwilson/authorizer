DOCKER_NAME=authorizer
DOCKER_COMMAND=docker-compose -f docker-compose.yml
LOCAL_TASK_URL=http://localhost:9000/2015-03-31/functions/function/invocations

upgrade_db_local:
	poetry run "alembic upgrade head"

migrate_db:
	${DOCKER_COMMAND} run authorizer bash -c "alembic revision --autogenerate -m \"DB migration\""

upgrade_db:
	${DOCKER_COMMAND} run authorizer bash -c "alembic upgrade head"

build:
	${DOCKER_COMMAND} build --build-arg INSTALL_DEV=true

build_prod:
	${DOCKER_COMMAND} build

# push last build image to ECR
push:
	bash ./scripts/push.sh

run:
	${DOCKER_COMMAND} up

stop:
	${DOCKER_COMMAND} down

test:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "pytest -s app"

lint:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "./scripts/lint.sh"

static:
	${DOCKER_COMMAND} run ${DOCKER_NAME} bash -c "./scripts/lint.sh --check"

task:
	curl -XPOST ${LOCAL_TASK_URL} -H "Content-Type: application/json" -d @./app/tests/data/mock_event.json
# Requires "make init_pipeline apply_pipeline" to be run in infra/ first
deploy:
	bash ./scripts/deploy.sh

clean:
	rm **/**/*.pyc
	rm **/**/__pycache__

delete_db_data:
	docker volume rm authorizer_db_data
	docker system prune