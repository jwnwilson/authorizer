import logging
import os

from alembic.config import Config
from alembic import command

logger = logging.getLogger(__name__)

def update_db(): 
    dsn = os.environ.get("DB_URL")
    logger.info(f"Running DB migrations on {dsn}")
    alembic_cfg = Config()
    # alembic_cfg.set_main_option("script_location", script_location)
    alembic_cfg.set_main_option("sqlalchemy.url", dsn)
    try:
        command.upgrade(alembic_cfg, "head")
    except Exception as err:
        logger.error(f"Error running DB migrations on {dsn}. {err}")
        raise
    logger.info(f"DB migrations complete on {dsn}")