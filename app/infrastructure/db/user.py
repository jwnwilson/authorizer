import os
from typing import Optional

from fastapi import Depends, HTTPException, Request, status
from fastapi_users import BaseUserManager, models
from fastapi_users.db import SQLAlchemyUserDatabase

from app.adapter.into.fastapi.exception import ErrorCode
from app.adapter.out.email import EmailService, EmailTemplateData
from app.infrastructure.db.base import get_user_db
from app.ports.users import UserCreate, UserDB

SECRET = os.environ["SECRET"]
EMAIL_ACCESS_TOKEN = os.environ["EMAIL_ACCESS_TOKEN"]
EMAIL_SERVICE_URL = os.environ["EMAIL_SERVICE_URL"]


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
        email_service = EmailService(
            service_url=EMAIL_SERVICE_URL, access_token=EMAIL_ACCESS_TOKEN
        )
        email_data = EmailTemplateData(
            user_id=user.id,
            subject="Password Reset",
            recipients=[user.email],
            template_id="password_reset",
            template_params={"email": user.email, "reset_token": token},
        )
        email_service.send_template(email_data)

    async def on_after_request_verify(
        self, user: UserDB, token: str, request: Optional[Request] = None
    ):
        print(f"Verification requested for user {user.id}. Verification token: {token}")
        email_service = EmailService(
            service_url=EMAIL_SERVICE_URL, access_token=EMAIL_ACCESS_TOKEN
        )
        email_data = EmailTemplateData(
            user_id=user.id,
            subject="Verify Account",
            recipients=[user.email],
            template_id="verify_account",
            template_params={"email": user.email, "verify_token": token},
        )
        email_service.send_template(email_data)

    async def update(
        self,
        user_update: models.UU,
        user: models.UD,
        safe: bool = False,
        request: Optional[Request] = None,
    ) -> models.UD:
        # Only allow scope update if superuser
        if user_update.scopes and not user.is_superuser:  # type: ignore
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "code": ErrorCode.INVALID_PERMISSIONS,
                    "reason": "Only superusers can modify user scopes",
                },
            )

        return await super().update(user_update, user, safe, request)  # type: ignore


async def get_user_manager(user_db: SQLAlchemyUserDatabase = Depends(get_user_db)):
    yield UserManager(user_db)
