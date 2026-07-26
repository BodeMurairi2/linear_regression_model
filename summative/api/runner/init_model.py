#!/usr/bin/env python3

import joblib
import shap
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
        explainer = shap.TreeExplainer(model)

        ressources = {
                "model":model,
                "scaler":scaler,
                "explainer":explainer,
                }
        ressources["retrain"] = RetrainModel(model=model, scaler=scaler, ressources=ressources)
        return ressources

@asynccontextmanager
async def load_model(app:FastAPI):
    app.state.ressources = init_model()
    yield
