import uvicorn
from fastapi import FastAPI

app = FastAPI(
    description="Predicting Malaria Prevalance in 1000 cases at risk",
    version="0.0.1",
    openapi_url="/swagger"
)

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
