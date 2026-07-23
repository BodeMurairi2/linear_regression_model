import uvicorn


from fastapi import FastAPI
from contextlib import asynccontextmanager
from api.routers.router import routing
from api.middlewares.cors_middleware import cors_middleware
from api.runner.init_model import load_model


app = FastAPI(
    description="Predicting Malaria Prevalance in 1000 cases at risk",
    version="0.0.1",
    openapi_url="/swagger",
    lifespan=load_model
)

routing(app=app)
cors_middleware(app=app)


@app.get("/")
async def welcome():
    return {
        "message":"Welcome"
    }

@app.get("/health")
async def status():
    return {
        "status":True,
        "message":"App running..."
    }

if __name__ == "__main__":
    uvicorn.run(
        "api.main:app",
        port=8000,
        reload=True
    )
