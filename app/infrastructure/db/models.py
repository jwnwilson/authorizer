from fastapi_users.db import (
    SQLAlchemyBaseOAuthAccountTable,
    SQLAlchemyBaseUserTable
)
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import DeclarativeMeta, declarative_base


Base: DeclarativeMeta = declarative_base()


class UserTable(Base, SQLAlchemyBaseUserTable):
    oauth_accounts = relationship("OAuthAccountTable")


class OAuthAccountTable(Base, SQLAlchemyBaseOAuthAccountTable):
    pass
