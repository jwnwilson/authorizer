from typing import Optional

from fastapi_users import models


class User(models.BaseUser):
    scopes: Optional[str]


class UserCreate(models.BaseUserCreate):
    pass


class UserUpdate(models.BaseUserUpdate):
    scopes: Optional[str]


class UserDB(User, models.BaseUserDB):
    pass
