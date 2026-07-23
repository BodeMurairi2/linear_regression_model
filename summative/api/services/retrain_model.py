#!/usr/bin/env python3

import threading
from typing import List, Any
from pathlib import Path

from fastapi import HTTPException, status

import joblib
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import StandardScaler

from api.schemas.retrain_model_schemas import RetrainRequest
from api.services.prediction import Prediction

class RetrainModel(Prediction):
    def __init__(self, model, scaler):
        super().__init__(model=model, scaler=scaler)
        self.__lock = threading.Lock()
        self.__is_training = False
        self.TARGET_COLUMN = "malaria_incidence_per_1000_at_risk"
        self.TRAINING_DATA_PATH = Path(__file__).parent.parent.parent/"linear_regression"/"malaria_control_africa.csv"
        self.MODEL_PATH = Path(__file__).parent.parent.parent / "linear_regression" / "model.pkl"
        self.SCALER_PATH = Path(__file__).parent.parent.parent / "linear_regression" / "scaler.pkl"
        self.__last_result = {
            "state": "idle",
            "detail": "No retraining has been run yet"
            }

    async def get_retrain_status(self):
        return {
            "is_training":self.__is_training,
            "last_result":self.__last_result
        }
    async def retrain_model(self, new_model, new_scaler):
        """This function retrain the model"""
        with self.__lock:
            self.__model = new_model
            self.__scaler = new_scaler

    async def launch_retraining(self, data:List[RetrainRequest]):
        """
        This function launches retraining
        """
        if self.__is_training:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A model retraining is running on background"
            )
        self.__is_training = True

        try:
            new_records = pd.DataFrame([row.model_dump() for row in data])
            existing_data = pd.read_csv(self.TRAINING_DATA_PATH)[self.FEATURES_COLUMNS + [self.TARGET_COLUMN]]
            combined_data = pd.concat([existing_data, new_records], ignore_index=True)

            features = combined_data[self.FEATURES_COLUMNS]
            target = combined_data[self.TARGET_COLUMN]

            new_scaler = StandardScaler()
            new_model = RandomForestRegressor(n_estimators=200, random_state=42)

            features_scaled = pd.DataFrame(new_scaler.fit_transform(features), columns=self.FEATURES_COLUMNS)
            new_model.fit(features_scaled, target)

            await self.retrain_model(new_model=new_model, new_scaler=new_scaler)

            joblib.dump(self.__model, self.MODEL_PATH)
            joblib.dump(self.__scaler, self.SCALER_PATH)

            combined_data.to_csv(self.TRAINING_DATA_PATH, index=False)

            self.__last_result = {
                "state":"success",
                "detail":f"Retrained on {len(combined_data)} total rows"
            }
        except Exception as error:
            self.__last_result = {
                            "state":"failed",
                            "detail":f"Fail to retrain:\nError:\n{str(error)}"
                        }
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail=f"An error occured:\n{error}"
            )
        finally:
            self.__is_training = False

        return {
            "status":True,
            "message":self.__last_result["detail"]
        }
