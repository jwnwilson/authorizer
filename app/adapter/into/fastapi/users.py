import os

from fastapi_users import FastAPIUsers
from fastapi_users.authentication import AuthenticationBackend, BearerTransport
from httpx_oauth.clients.google import GoogleOAuth2

from app.infrastructure.auth import get_jwt_strategy
from app.infrastructure.db.user import get_user_manager
from app.ports.users import User, UserCreate, UserDB, UserUpdate

SECRET = os.environ["SECRET"]
EMAIL_ACCESS_TOKEN = os.environ["EMAIL_ACCESS_TOKEN"]
EMAIL_SERVICE_URL = os.environ["EMAIL_SERVICE_URL"]


google_oauth_client = GoogleOAuth2(
    os.environ["GOOGLE_OAUTH_CLIENT_ID"],
    os.environ["GOOGLE_OAUTH_CLIENT_SECRET"],
)

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
