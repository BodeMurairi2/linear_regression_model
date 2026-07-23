#!/usr/bin/env python3

from typing import List, Optional
from api.schemas.prediction_schemas import PredictionRequest
from pydantic import Field

class RetrainRequest(PredictionRequest):
    """
    BaseModel for retraining the model
    """
    malaria_incidence_per_1000_at_risk: float = Field(
        description="Actual observed malaria incidence per 1,000 at risk",
        ge = 0,
        le = 1000
    )
