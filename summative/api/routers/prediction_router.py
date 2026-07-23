#!/usr/bin/env python3

from fastapi import Request
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
async def predict_cases(
    predict_cases:PredictionRequest,
    request:Request
    ):
    """
    This is the prediction router
    """
    ressources = request.app.state.ressources
    prediction = Prediction(model=ressources["model"], scaler=ressources["scaler"])
    return await prediction.predict_malaria_incidence(user_prediction=predict_cases)
