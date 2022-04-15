import os
import time
from typing import Optional

import jwt
from fastapi import Depends, Request
from fastapi_users import BaseUserManager, FastAPIUsers, models
from fastapi_users.authentication import (
    AuthenticationBackend,
    BearerTransport,
    JWTStrategy,
)
from fastapi_users.db import SQLAlchemyUserDatabase
from fastapi_users.jwt import decode_jwt, generate_jwt
from httpx_oauth.clients.google import GoogleOAuth2

from app.infrastructure.db.base import get_user_db
from app.ports.users import User, UserCreate, UserDB, UserUpdate

SECRET = os.environ["SECRET"]


google_oauth_client = GoogleOAuth2(
    os.environ["GOOGLE_OAUTH_CLIENT_ID"],
    os.environ["GOOGLE_OAUTH_CLIENT_SECRET"],
)


class UserManager(BaseUserManager[UserCreate, UserDB]):
    user_db_model = UserDB
    reset_password_token_secret = SECRET
    verification_token_secret = SECRET

    async def on_after_register(self, user: UserDB, request: Optional[Request] = None):
        print(f"User {user.id} has registered.")

    async def on_after_forgot_password(
        self, user: UserDB, token: str, request: Optional[Request] = None
    ):
        print(f"User {user.id} has forgot their password. Reset token: {token}")

    async def on_after_request_verify(
        self, user: UserDB, token: str, request: Optional[Request] = None
    ):
        print(f"Verification requested for user {user.id}. Verification token: {token}")


async def get_user_manager(user_db: SQLAlchemyUserDatabase = Depends(get_user_db)):
    yield UserManager(user_db)


class JWTNoDBStrategy(JWTStrategy):
    def _get_token_data(self, token) -> dict:
        """Decode JWT token and get the payload"""
        try:
            return decode_jwt(token, self.secret, self.token_audience)
        except jwt.PyJWTError:
            return {}

    def _check_token_data_expired(self, data: dict) -> Optional[dict]:
        """Check if JWT token has expired from it's payload"""
        if data["exp"] > time.time():
            return None
        return data

    async def read_token(
        self, token: Optional[str], user_manager: BaseUserManager[models.UC, models.UD]
    ) -> Optional[models.UD]:
        data = self._get_token_data(token)
        if self._check_token_data_expired(data):
            return None
        return await super().read_token(token, user_manager)

    def read_token_no_db(self, token: str) -> Optional[UserDB]:
        if token is None:
            return None

        data = self._get_token_data(token)
        user_id = data.get("user_id")
        if user_id is None:
            return None
        if self._check_token_data_expired(data):
            return None

        try:
            data["id"] = user_id
            data.pop("user_id")
            return UserDB(**data)
        except ValueError:
            return None

    async def write_token(self, user: models.UD) -> str:
        data = user.dict()
        data["user_id"] = str(data["id"])
        data["aud"] = self.token_audience
        data.pop("id")
        return generate_jwt(data, self.secret, self.lifetime_seconds)


def get_jwt_strategy() -> JWTNoDBStrategy:
    return JWTNoDBStrategy(secret=SECRET, lifetime_seconds=3600)


bearer_transport = BearerTransport(tokenUrl="auth/jwt/login")

auth_backend = AuthenticationBackend(
    name="jwt",
    transport=bearer_transport,
    get_strategy=get_jwt_strategy,
)
fastapi_users = FastAPIUsers(
    get_user_manager,
    [auth_backend],
    User,
    UserCreate,
    UserUpdate,
    UserDB,
)

current_active_user = fastapi_users.current_user(active=True)
