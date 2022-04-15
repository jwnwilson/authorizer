def test_api_root(client):
    response = client.get("/docs")
    assert response.status_code == 200


def test_non_superuser_change_scope(client):
    pass
