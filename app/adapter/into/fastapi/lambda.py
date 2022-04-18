import logging

from mangum import Mangum

# Initialize you log configuration using the base class
logging.basicConfig(level=logging.INFO)
logging.getLogger().setLevel(logging.INFO)

from .app import app

# To plug into lambda
mangum_handler = Mangum(app)


def lambda_handler(event, context):
    # Skip if this is an event bridge keep warm event
    if "detail" in event:
        logging.debug("Event bridge event, skipping")
        return
    return mangum_handler(event, context)
