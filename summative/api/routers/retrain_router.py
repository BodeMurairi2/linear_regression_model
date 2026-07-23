#!/usr/bin/env python3

from typing import List
from fastapi import Request, BackgroundTasks
from fastapi.routing import APIRouter
from api.schemas.retrain_model_schemas import RetrainRequest
from api.services.retrain_model import RetrainModel

router = APIRouter(
    prefix="/retrain",
    tags=["Retrains the malaria model"]
    )

@router.post("/")
async def retrain_model(
    data:List[RetrainRequest],
    request:Request,
    background_tasks:BackgroundTasks
    ):
    """
    Triggler a background job retraining the model on new submitted data,
    this combined with the existing training set
    """
    ressources = request.app.state.ressources
    retrain = ressources["retrain"]

    background_tasks.add_task(retrain.launch_retraining, data=data)

    return {
        "status":True,
        "message":"Model retraining running in the background"
    }

@router.get("/status")
async def retrain_status(request:Request):
    retrain_service = request.app.state.ressources["retrain"]
    return await retrain_service.get_retrain_status()
