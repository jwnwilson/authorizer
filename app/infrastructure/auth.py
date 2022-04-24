import os
import time
from typing import Optional

import jwt
from fastapi_users import BaseUserManager, models
from fastapi_users.authentication import JWTStrategy
from fastapi_users.jwt import decode_jwt, generate_jwt

from app.ports.users import UserDB

SECRET = os.environ["SECRET"]


class JWTNoDBStrategy(JWTStrategy):
    def _get_token_data(self, token) -> dict:
        """Decode JWT token and get the payload"""
        try:
            return decode_jwt(token, self.secret, self.token_audience)
        except jwt.PyJWTError:
            return {}

    def _token_data_expired(self, data: dict) -> bool:
        """Check if JWT token has expired from it's payload"""
        if "exp" in data and data["exp"] < time.time():
            return True
        return False

    async def read_token(
        self, token: Optional[str], user_manager: BaseUserManager[models.UC, models.UD]
    ) -> Optional[models.UD]:
        data = self._get_token_data(token)
        if self._token_data_expired(data):
            return None
        return await super().read_token(token, user_manager)

    def read_token_no_db(self, token: str) -> Optional[UserDB]:
        if token is None:
            return None

        data = self._get_token_data(token)
        user_id = data.get("user_id")
        if user_id is None:
            return None
        if self._token_data_expired(data):
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


def get_jwt_strategy(lifetime_seconds: int = 3600) -> JWTNoDBStrategy:
    return JWTNoDBStrategy(secret=SECRET, lifetime_seconds=lifetime_seconds)
