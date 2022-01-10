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
	docker-compose run api bash -c "pytest app"

lint:
	docker-compose run api bash -c "scripts/lint.sh"

static:
	docker-compose run api bash -c "scripts/lint.sh --check"

# Requires "make init_pipeline apply_pipeline" to be run in infra/ first
deploy:
	bash ./scripts/deploy.sh

clean:
	rm **/**/*.pyc
	rm **/**/__pycache__