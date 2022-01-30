import pytest
import os

os.environ["DB_URL"] = "sqlite+aiosqlite:///db.sqlite"

from fastapi.testclient import TestClient
from adapter.out.alembic.upgrade import update_db


@pytest.fixture
def client(db):
    from adapter.into.fastapi.app import app

    return TestClient(app)


@pytest.fixture(autouse=True)
def db():
    update_db()


@pytest.fixture
def test_username_password():
    return {
        "username": "user@example.com",
        "password": "string",
    }


@pytest.fixture
def create_test_user(client, test_username_password):
    response = client.post("/auth/register", json={
        "email": test_username_password["username"],
        "password": test_username_password["password"]
    })
    return response.json()


@pytest.fixture
def login_test_user(client, create_test_user, test_username_password): 
    response = client.post("/auth/jwt/login", data=test_username_password)
    return response.json()