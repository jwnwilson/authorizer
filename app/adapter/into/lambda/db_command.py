import logging

# Initialize you log configuration using the base class
logging.basicConfig(level=logging.INFO)
logging.getLogger().setLevel(logging.INFO)

from app.adapter.out.alembic.upgrade import update_db


def lambda_handler(event, context):
    update_db()