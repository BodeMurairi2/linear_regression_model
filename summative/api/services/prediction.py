#!/usr/bin/env python3

import pandas as pd

from api.schemas.prediction_schemas import (
    FeatureContribution,
    PredictionRequest,
    PredictionResponse,
)

class Prediction:
    def __init__(self, model, scaler, explainer=None):
        self.__model = model
        self.__scaler = scaler
        self.__explainer = explainer

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
                number_case_malaria=max(0.0, round(float(prediction), 0)),
                feature_contributions=self.__feature_contributions(input_scaled)
            )
        }

    def __feature_contributions(self, input_scaled: pd.DataFrame):
        """
        Per-feature SHAP contributions for this single prediction, sorted by
        |contribution| descending. Returns None if no explainer was configured.
        """
        if self.__explainer is None:
            return None

        shap_values = self.__explainer.shap_values(input_scaled)[0]
        contributions = [
            FeatureContribution(feature=feature, contribution=round(float(value), 2))
            for feature, value in zip(self.FEATURES_COLUMNS, shap_values)
        ]
        contributions.sort(key=lambda item: abs(item.contribution), reverse=True)
        return contributions
