from fastapi import FastAPI
from api.routers.prediction_router import router as prediction_router

def routing(app:FastAPI):
    app.include_router(prediction_router)
