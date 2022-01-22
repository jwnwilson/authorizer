DOCKER_NAME=authorizer

migrate_db:
	docker-compose run authorizer bash -c "alembic revision --autogenerate -m \"DB migration\""

upgrade_db:
	docker-compose run authorizer bash -c "alembic upgrade head"

upgrade_db_local:
	docker-compose -f docker-compose.yml -f docker-compose.local-db.yml run authorizer bash -c "alembic upgrade head"

build:
	docker-compose build --build-arg INSTALL_DEV=true

# push last build image to ECR
push:
	bash ./scripts/push.sh

run:
	docker-compose up

stop:
	docker-compose down

test:
	docker-compose run ${DOCKER_NAME} bash -c "pytest app"

lint:
	docker-compose run ${DOCKER_NAME} bash -c "scripts/lint.sh"

static:
	docker-compose run ${DOCKER_NAME} bash -c "scripts/lint.sh --check"

# Requires "make init_pipeline apply_pipeline" to be run in infra/ first
deploy:
	bash ./scripts/deploy.sh

clean:
	rm **/**/*.pyc
	rm **/**/__pycache__