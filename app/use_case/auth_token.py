from fastapi_users.db import SQLAlchemyUserDatabase

from app.infrastructure.users import get_jwt_strategy, get_user_manager, UserManager
from app.infrastructure.db.models import UserTable
from app.infrastructure.db.base import get_async_session_maker
from app.ports.users import UserDB


async def get_user_from_token(token):
    async_session_maker = get_async_session_maker()
    async with async_session_maker() as session:
        user_db = SQLAlchemyUserDatabase(UserDB, session, UserTable)
        user_manager = UserManager(user_db)
        return await get_jwt_strategy().read_token(token, user_manager)
