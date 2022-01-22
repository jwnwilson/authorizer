from typing import AsyncGenerator

import sqlalchemy as sa
from fastapi import Depends
from fastapi_users.db import SQLAlchemyUserDatabase
from fastapi_users_db_sqlalchemy.guid import GUID
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.ext.declarative import DeclarativeMeta, declarative_base
from sqlalchemy.orm import sessionmaker

from app.config import settings
from app.utils import utcnow
from app.ports.users import UserDB

engine = create_async_engine(
    settings.DB_DSN,
    echo=settings.DB_ECHO,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
)
async_session_maker = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)
Base: DeclarativeMeta = declarative_base()


async def create_db_and_tables():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def get_async_session() -> AsyncGenerator[AsyncSession, None]:
    async with async_session_maker() as session:
        yield session


async def get_user_db(session: AsyncSession = Depends(get_async_session)):
    from .models import UserTable

    yield SQLAlchemyUserDatabase(UserDB, session, UserTable)


class EmptyBaseModel(Base):
    """Clean Base without fields and methods"""

    __abstract__ = True


class BaseModel(Base):
    __abstract__ = True

    id = sa.Column(GUID, primary_key=True)
    created_at = sa.Column(sa.DateTime(timezone=True), default=utcnow, nullable=False)
    updated_at = sa.Column(
        sa.DateTime(timezone=True), default=utcnow, onupdate=utcnow, nullable=False
    )

    def __str__(self):
        return f"<{type(self).__name__}({self.id=})>"
