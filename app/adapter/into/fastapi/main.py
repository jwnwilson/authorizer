import os

from fastapi import FastAPI

from .routes import pdf_generation, pdf_template

ENVIRONMENT = os.environ.get("ENVIRONMENT", "")

root_prefix = f"/"

app = FastAPI(
    title="Auth Service",
    description="Auth service",
    version="0.0.1",
    root_path=root_prefix,
)


@app.get("/")
async def version():
    return {"message": "auth service"}
