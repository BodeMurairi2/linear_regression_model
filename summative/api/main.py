import uvicorn
from fastapi import FastAPI
from .router import router as prediction_router

app = FastAPI(
    description="Predicting Malaria Prevalance in 1000 cases at risk",
    version="0.0.1",
    openapi_url="/swagger"
)

app.include_router(prediction_router)

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
