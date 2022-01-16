import os

from pydantic import BaseSettings
from sqlalchemy.engine.url import URL


class Settings(BaseSettings):
    SERVICE_NAME: str = "FastApi"
    DEBUG: bool = False

    DB_URL: str = os.environ["DB_URL"]
    DB_POOL_SIZE: int = 5
    DB_MAX_OVERFLOW: int = 0
    DB_ECHO: bool = False

    @property
    def DB_DSN(self) -> URL:
        return self.DB_URL

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
