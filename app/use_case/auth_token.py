import os
from typing import Optional

import jwt
from fastapi_users.jwt import decode_jwt

from app.adapter.into.fastapi.users import get_jwt_strategy

from app.ports.users import UserDB
SECRET = os.environ["SECRET"]


def get_user_from_token(token) -> Optional[UserDB]:
    return get_jwt_strategy().read_token_no_db(token)
