#!/usr/bin/env python3

import joblib
from pathlib import Path

from contextlib import asynccontextmanager
from fastapi import FastAPI

from api.services.retrain_model import RetrainModel

def init_model():
        """Init model"""
        MODEL_PATH = Path(__file__).parent.parent.parent / "linear_regression" / "model.pkl"
        SCALER_PATH = Path(__file__).parent.parent.parent / "linear_regression" / "scaler.pkl"

        model = joblib.load(filename=MODEL_PATH)
        scaler = joblib.load(filename=SCALER_PATH)
        return {
                "model":model,
                "scaler":scaler,
                "retrain":RetrainModel(model=model, scaler=scaler)
                }

@asynccontextmanager
async def load_model(app:FastAPI):
    app.state.ressources = init_model()
    yield
