import os
import jwt
from typing import Optional

from fastapi import Depends, Request
from fastapi_users import models
from fastapi_users.jwt import decode_jwt, generate_jwt
from fastapi_users import BaseUserManager, FastAPIUsers
from fastapi_users.authentication import (
    AuthenticationBackend,
    BearerTransport,
    JWTStrategy,
)
from fastapi_users.db import SQLAlchemyUserDatabase
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
    async def read_token(
        self, token: Optional[str], user_manager: BaseUserManager[models.UC, models.UD]
    ) -> Optional[models.UD]:
        if token is None:
            return None

        try:
            data = decode_jwt(token, self.secret, self.token_audience)
            user_id = data.get("id")
            if user_id is None:
                return None
        except jwt.PyJWTError:
            return None

        try:
            return UserDB(
                **data
            )
        except ValueError:
            return None

    async def write_token(self, user: models.UD) -> str:
        data = user.dict()
        data["aud"] = self.token_audience
        return generate_jwt(data, self.secret, self.lifetime_seconds)


def get_jwt_strategy() -> JWTStrategy:
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
