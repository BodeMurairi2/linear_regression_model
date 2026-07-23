#!/usr/bin/env python3

from fastapi.routing import APIRouter
from api.schemas.prediction_schemas import PredictionRequest, PredictionResponse
from api.services.prediction import Prediction

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
    prediction = Prediction()
    return await prediction.predict_malaria_incidence(user_prediction=predict_cases)
