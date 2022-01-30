def test_api_root(client):
    response = client.get("/docs")
    assert response.status_code == 200
