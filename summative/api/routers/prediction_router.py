#!/usr/bin/env python3

from fastapi import Request
from fastapi.routing import APIRouter
from api.schemas.prediction_schemas import PredictionRequest, PredictionResponse
from api.services.prediction import Prediction

router = APIRouter(
    prefix="/predictions",
    tags=["Predicts Malaria cases"]
)

@router.post("/")
async def predict_cases(
    predict_cases:PredictionRequest,
    request:Request
    ):
    """
    This is the prediction router
    Args:
        predict_cases:Pydantic schema
        request:Request (FastAPI request class)
    """
    ressources = request.app.state.ressources
    prediction = Prediction(
        model=ressources["model"],
        scaler=ressources["scaler"],
        explainer=ressources.get("explainer"),
    )
    return await prediction.predict_malaria_incidence(user_prediction=predict_cases)
