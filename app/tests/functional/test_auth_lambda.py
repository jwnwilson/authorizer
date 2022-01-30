import pytest
from use_case.auth_token import get_user_from_token


@pytest.mark.asyncio
async def test_get_user(login_test_user):
    user = await get_user_from_token(login_test_user["access_token"])
    assert user is not None
