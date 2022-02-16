import jwt
import os
from fastapi_users.jwt import decode_jwt

from app.ports.users import UserDB
from app.infrastructure.users import get_jwt_strategy

SECRET = os.environ["SECRET"]


def get_user_from_token(token) -> UserDB:
    return get_jwt_strategy().read_token_no_db(token)
