import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def client():
    from adapter.into.fastapi.app import app


    return TestClient(app)
