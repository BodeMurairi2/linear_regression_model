#!/usr/bin/env python3

from fastapi.routing import APIRouter
from .schemas import PredictionRequest, PredictionResponse

router = APIRouter(
    prefix="/predictions",
    tags=["Predicts Malaria cases"]
)

@router.get("/")
async def get_all_predictions():
    return {
        "message":"Predictions running"
    }

@router.post("/")
async def predict_cases(predict_cases:PredictionRequest):
    """
    This is the prediction router
    """
    return {
        "status":True,
        "data":PredictionResponse()
    }
