def test_api_root(client):
    response = client.get("/docs")
    assert response.status_code == 200


# def test_create_pdf_task(client):
#     response = client.post("/pdf")
#     assert response.status_code == 200
#     assert response.json() == {"message": "pdf generator service"}
