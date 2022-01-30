import logging
import os

from alembic import command
from alembic.config import Config
from config import settings

logger = logging.getLogger(__name__)


def update_db():
    dsn = settings.DB_DSN
    logger.info(f"Running DB migrations on {dsn}")
    alembic_cfg = Config()
    alembic_cfg.set_main_option("script_location", "migrations")
    alembic_cfg.set_main_option("sqlalchemy.url", dsn)
    try:
        command.upgrade(alembic_cfg, "head")
    except Exception as err:
        logger.error(f"Error running DB migrations on {dsn}. {err}")
        raise
    logger.info(f"DB migrations complete on {dsn}")
