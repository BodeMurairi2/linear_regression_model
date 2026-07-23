#!/usr/bin/env python3

import joblib
import pandas as pd
from pathlib import Path

from .schemas import PredictionRequest, PredictionResponse

class Prediction:
    def __init__(self):
        self.MODEL_PATH = Path(__file__).parent.parent / "linear_regression" / "model.pkl"
        self.SCALER_PATH = Path(__file__).parent.parent / "linear_regression" / "scaler.pkl"

        self.__model = joblib.load(filename=self.MODEL_PATH)
        self.__scaler = joblib.load(filename=self.SCALER_PATH)

        self.FEATURES_COLUMNS = [
            "health_expenditure_per_capita_usd",
            "rural_population_pct",
            "gdp_per_capita_usd",
            "forest_area_pct",
            "population_density",
            "under5_mortality_per_1000",
            "life_expectancy_years",
            "basic_water_access_pct",
            "govt_health_exp_pct_gdp",
            "primary_completion_rate_pct",
            "fertility_rate_births_per_woman",
            ]


    async def predict_malaria_incidence(
            self,
            user_prediction: PredictionRequest
            ) -> float:
        """
        This function takes a prediction request and return a prediction response
        """
        input_data = pd.DataFrame([user_prediction.model_dump()])[self.FEATURES_COLUMNS]
        input_scaled = pd.DataFrame(self.__scaler.transform(input_data), columns=self.FEATURES_COLUMNS)
        prediction = self.__model.predict(input_scaled)[0]
        return {
            "status":True,
            "Prediction":PredictionResponse(
                number_case_malaria=max(0.0, round(float(prediction), 0))
            )
        }
