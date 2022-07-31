import asyncio
import logging
import os

# Initialize you log configuration using the base class
logging.basicConfig(level=logging.INFO)
logging.getLogger().setLevel(logging.INFO)

from app.adapter.into.cli.commands.generate_service_token import generate_service_token


def lambda_handler(event, context):
    user_id = os.environ["SERVICE_TOKEN_USER"]
    loop = asyncio.get_event_loop()
    loop.run_until_complete(generate_service_token(user_id))
    loop.close()