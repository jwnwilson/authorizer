from fastapi_users.db import SQLAlchemyUserDatabase

from app.infrastructure.auth import get_jwt_strategy
from app.infrastructure.db.base import get_async_session_maker
from app.infrastructure.db.models import UserTable
from app.infrastructure.db.user import UserManager
from app.ports.users import UserDB


async def generate_service_token(user_id):
    async_session_maker = get_async_session_maker()
    async with async_session_maker() as session:
        sql_adapter = SQLAlchemyUserDatabase(UserDB, session, UserTable)
        user_adapter = UserManager(sql_adapter)
        user: UserDB = await user_adapter.get(user_id)

    jwt_strat = get_jwt_strategy(lifetime_seconds=None)
    token = await jwt_strat.write_token(user)
    print(token)
