import logging
from typing import TypeVar

from sqlalchemy import MetaData
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import declarative_base, sessionmaker

from config import settings

logger = logging.getLogger(__name__)
TBase = TypeVar("TBase", bound="BaseModel")


engine = create_async_engine(
    settings.DB_DSN,
    echo=settings.DB_ECHO,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    future=True,
)
async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession, future=True)
metadata = MetaData()
Base = declarative_base(metadata=metadata)
