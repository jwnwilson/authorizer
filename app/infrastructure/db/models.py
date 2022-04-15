from fastapi_users.db import SQLAlchemyBaseOAuthAccountTable, SQLAlchemyBaseUserTable
from sqlalchemy.orm import relationship
import sqlalchemy as sa

from .base import BaseModel


class UserTable(BaseModel, SQLAlchemyBaseUserTable):
    oauth_accounts = relationship("OAuthAccountTable")
    scopes = sa.Column(sa.String)


class OAuthAccountTable(BaseModel, SQLAlchemyBaseOAuthAccountTable):
    pass
