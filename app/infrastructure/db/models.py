from fastapi_users.db import (
    SQLAlchemyBaseOAuthAccountTable,
    SQLAlchemyBaseUserTable
)
from sqlalchemy.orm import relationship

from .base import BaseModel


class UserTable(BaseModel, SQLAlchemyBaseUserTable):
    oauth_accounts = relationship("OAuthAccountTable")


class OAuthAccountTable(BaseModel, SQLAlchemyBaseOAuthAccountTable):
    pass
