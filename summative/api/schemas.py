from typing import Optional
from pydantic import BaseModel, Field

class PredictionRequest(BaseModel):
    """
    BaseClass for All POST Prediction
    """
    health_expenditure_per_capita_usd:float = Field(description="Average amount in USD paid per capita for health", ge=0, le=1000)
    rural_population_pct:float = Field(description="Percentage of population living in rural areas", ge=0, le=100)
    gdp_per_capita_usd:float = Field(description="Country GDP per capita in USD", ge=0, le=25000)
    population_density:float = Field(description="Country population density (people per sq km)", ge=0, le=800)
    forest_area_pct:float = Field(description="Percentage of forest area", ge=0, le=100)
    under5_mortality_per_1000:float = Field(description="Ratio per 1000 of children under 5 mortality", ge=0, le=600)
    life_expectancy_years:float = Field(description="Population life expectancy in years", ge=0, le=100)
    basic_water_access_pct:float = Field(description="Percentage of population with access to basic drinking water", ge=0, le=100)
    govt_health_exp_pct_gdp:float = Field(description="Percentage of GDP allocated to health by government", ge=0, le=20)
    primary_completion_rate_pct:float = Field(description="Percentage of population who has completed primary school (can exceed 100 due to over-age enrollment)", ge=0, le=120)
    fertility_rate_births_per_woman:float = Field(description="Average number of births per woman", ge=1, lt=10)

class PredictionResponse(BaseModel):
    """
    PredictionResponse
    """
    number_case_malaria:Optional[float] = Field(description="Number of case of malaria per One thousand case at risk", default=250)

prediction = PredictionRequest(
    health_expenditure_per_capita_usd=250,
    rural_population_pct=50,
    gdp_per_capita_usd=1200,
    population_density=80,
    forest_area_pct=30,
    under5_mortality_per_1000=52,
    life_expectancy_years=62,
    basic_water_access_pct=60,
    govt_health_exp_pct_gdp=2.5,
    primary_completion_rate_pct=70,
    fertility_rate_births_per_woman=5.2
    )

print(prediction.model_dump(mode="json"))
