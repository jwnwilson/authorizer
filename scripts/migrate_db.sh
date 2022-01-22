#! /bin/bash

make bastion_db_tunnel &

export DB_URL="postgresql+asyncpg://postgres:password@localhost:5432/authorizer"

poetry run "alembic upgrade head" 