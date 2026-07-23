from fastapi import FastAPI
from api.routers.prediction_router import router as prediction_router
from api.routers.retrain_router import router as retrain_router

def routing(app:FastAPI):
    app.include_router(prediction_router)
    app.include_router(retrain_router)
