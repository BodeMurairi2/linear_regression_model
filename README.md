# Malaria Prevalence Estimator

## Mission

Malaria has been one of the diseases that many African countries have suffered from, with a detrimental impact on healthcare and social life across the continent. This project's mission is to estimate a country's malaria burden (cases per 1,000 population at risk) from socioeconomic and health-system indicators — GDP, health spending, water access, education — across 52 African countries, 2000–2024.

This is population-level regression, not individual risk prediction: it identifies patterns associated with higher or lower malaria incidence. It estimates malaria burden for countries based on their socioeconomic and health-system conditions, to support surveillance and policy prioritization.

---

## Key Results

- **1,176 observations** across **52 countries** and **11 features**
- **4 regression models** compared: OLS, SGD, Decision Tree, Random Forest
- **Random Forest selected** — Test R² = **94.11%**, Test RMSE = **41.16**, Test MAE = **24.14**
- Deployed as a **FastAPI** service with **SHAP** explanations attached to every prediction
- Includes a **retraining endpoint** that updates the live model without a server restart

---

## Data Source

The dataset is assembled from two independent, public sources: the World Health Organization and the World Bank. Both are live APIs, merged programmatically — every value traces back to an official published statistic.

`scripts.py` shows step by step how the two raw data sources were acquired.

### Sources

| Source | Endpoint | Last updated |
|---|---|---|
| WHO Global Health Observatory — estimated malaria incidence (target variable) | `https://ghoapi.azureedge.net/api/MALARIA_EST_INCIDENCE` | 2025-12-19 (confirmed via the API's own per-record `Date` field — WHO refreshes this series in an annual batch alongside the World Malaria Report) |
| World Bank Open Data — 13 socioeconomic/health indicators (features) | `https://api.worldbank.org/v2/country/{iso3-codes}/indicator/{code}?date=2000:2024&format=json` | 2026-07-13 (confirmed via the World Development Indicators source's own `lastupdated` metadata field — this source is revised continuously) |

Both dates can be verified by querying the live APIs directly.

### World Bank indicators used

| Indicator code | Feature name | Description |
|---|---|---|
| `SH.XPD.CHEX.PC.CD` | `health_expenditure_per_capita_usd` | Current health expenditure per capita (USD) |
| `SH.XPD.GHED.GD.ZS` | `govt_health_exp_pct_gdp` | Domestic general government health expenditure (% of GDP) |
| `SH.DYN.MORT` | `under5_mortality_per_1000` | Under-5 mortality rate (per 1,000 live births) |
| `SP.DYN.LE00.IN` | `life_expectancy_years` | Life expectancy at birth (years) |
| `SH.H2O.BASW.ZS` | `basic_water_access_pct` | People using at least basic drinking water services (% of population) |
| `NY.GDP.PCAP.CD` | `gdp_per_capita_usd` | GDP per capita (current USD) |
| `EN.POP.DNST` | `population_density` | Population density (people per km² of land area) |
| `SP.RUR.TOTL.ZS` | `rural_population_pct` | Rural population (% of total population) |
| `SP.DYN.TFRT.IN` | `fertility_rate_births_per_woman` | Fertility rate, total (births per woman) |
| `AG.LND.FRST.ZS` | `forest_area_pct` | Forest area (% of land area) |
| `SE.PRM.CMPT.ZS` | `primary_completion_rate_pct` | Primary completion rate (% of relevant age group — can exceed 100% due to over-age enrollment) |
| `SP.URB.TOTL.IN.ZS` | *(dropped — see below)* | Urban population (% of total population) |
| `SP.POP.TOTL` | *(dropped — see below)* | Total population |

### How the two datasets were collected and combined

1. **Fetch** — WHO malaria data is pulled with one API call, filtered server-side to the 54 African ISO3 codes. World Bank data requires 13 separate API calls (one per indicator — the World Bank API has no "all indicators at once" endpoint), fetched concurrently.
2. **Merge indicators** — the 13 World Bank responses are combined into one wide table via chained outer joins on `(iso3, year)`.
3. **Merge sources** — the WHO table is inner-joined to the World Bank table on `(iso3, year)`, then explicitly sorted alphabetically by country and ascending by year, producing `malaria_control_africa.csv`, kept on disk untouched as a raw before/after reference.
4. **Handle missing data** — `primary_completion_rate_pct` was ~40% missing. A global mean fill was tested and rejected: it weakened its correlation with the target from −0.563 to −0.460, an 18% distortion. Within-country linear interpolation was used instead — filling a gap using the real observations before and after it — and produced substantially less change in the feature-target relationship (−0.550, only 0.013 off).
5. **Drop unrecoverable rows** — Djibouti and Somalia were excluded because they had no primary completion-rate observations throughout the study period, leaving nothing for interpolation to work from.
6. **Feature selection** — `iso3`/`country` (identifiers), `urban_population_pct` (perfect −1.00 collinearity with `rural_population_pct`, the complement kept for its more direct epidemiological relevance), `population_total` (near-zero correlation with the target; `population_density` is the better proxy for mosquito–human contact rate), and `year` (the model is about socioeconomic/health drivers, not a time trend) were all dropped.
7. **Output** — the cleaned, standardization-ready data is saved separately as `clean_malaria_control_africa.csv`, kept apart from the raw file so the "before" and "after" of the cleaning pipeline are both inspectable.

---

## Model Background & Performance

Four regression approaches were trained and compared: Ordinary Least Squares, SGD (manual gradient-descent loop with an explicit train/test loss curve), a depth-tuned Decision Tree, and a Random Forest.

| | OLS | SGD | Decision Tree | Random Forest |
|---|---|---|---|---|
| Train RMSE | 101.38 | 101.39 | 7.46 | 14.36 |
| Test RMSE | 109.98 | 109.98 | 48.58 | **41.16** |
| Train MAE | 82.57 | 82.65 | 2.19 | 9.12 |
| Test MAE | 85.08 | 85.19 | **23.23** | 24.14 |
| Test R² | 57.96% | 57.97% | 91.80% | **94.11%** |

**Random Forest was selected as the best-performing model.** It had the best Test RMSE (41.16) and Test R² (94.11%), despite Decision Tree scoring slightly better on Test MAE (23.23 vs. 24.14). Since RMSE penalizes larger errors more heavily than MAE, Random Forest's advantage in RMSE indicates better performance on larger prediction errors. This makes Random Forest the strongest overall model according to the selected evaluation metrics. OLS and SGD converge to essentially the same linear solution and only capture ~58% of the variance, suggesting that nonlinear models capture important patterns in this relationship that linear models fail to capture.

---

## Evaluation Scope

The model is designed to estimate malaria burden from a country's socioeconomic and health conditions in a given year — not to forecast malaria incidence in a future year such as 2026. Accordingly, an 80/20 random train-test split was used across country-year observations rather than a temporal split. This evaluates the model's ability to generalize to unseen observations from the studied countries, rather than its ability to forecast future years or generalize to entirely unseen countries.

---

## API

**Live, publicly routable API:** `https://malaria-prevalence.onrender.com`
**Swagger UI:** [`https://malaria-prevalence.onrender.com/docs`](https://malaria-prevalence.onrender.com/docs)

### `POST /predictions/`
Accepts 11 socioeconomic/health features (each with an enforced `float` type and a realistic range constraint via Pydantic), returns the estimated malaria incidence plus a per-feature SHAP contribution breakdown explaining the prediction.

```json
{
  "health_expenditure_per_capita_usd": 45,
  "rural_population_pct": 62,
  "gdp_per_capita_usd": 2100,
  "population_density": 220,
  "forest_area_pct": 18,
  "under5_mortality_per_1000": 95,
  "life_expectancy_years": 58,
  "basic_water_access_pct": 52,
  "govt_health_exp_pct_gdp": 4.2,
  "primary_completion_rate_pct": 68,
  "fertility_rate_births_per_woman": 5.1
}
```

Returns `422` with a clear validation message if a field is missing or out of range.

### `POST /retrain/`
Accepts new labeled rows (the 11 features plus the true `malaria_incidence_per_1000_at_risk`) and retrains a Random Forest on the combined dataset in the background. See **Retraining Scope** below for how the update persists. `GET /retrain/status` reports progress and the last result.

---

## CORS Configuration

```python
allow_origins=["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:5000", "http://127.0.0.1:5000"]
allow_credentials=False
allow_methods=["GET", "POST"]
allow_headers=["Content-Type"]
```

Each setting was chosen deliberately:
- **Methods** are limited to `GET`/`POST` — the API only reads status and makes predictions; there's nothing to `PUT` or `DELETE`.
- **Credentials** are disabled — this is a stateless prediction API with no cookie- or session-based authentication, so there's nothing to carry across origins.
- **Origins** are scoped to local development ports rather than a wildcard, since there is no deployed web frontend for this API — the Flutter mobile app is not subject to CORS, since CORS only restricts browser-based requests.

---

## Repository Structure

```
linear_regression_model/
├── README.md                    # this file
├── pyproject.toml, uv.lock      # Python dependency management (uv)
├── requirements.txt             # pinned dependencies for local dev and render
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb                       # full notebook: EDA, cleaning, training, model comparison
│   │   ├── scripts.py                                # fetches the two raw datasets from the WHO/World Bank APIs
│   │   ├── who_malaria_incidence_raw.csv             # raw, untouched WHO API pull
│   │   ├── worldbank_indicators_raw.csv              # raw, untouched World Bank API pull
│   │   ├── malaria_control_africa.csv                # merged dataset, before cleaning ("before" reference)
│   │   ├── clean_malaria_control_africa.csv          # cleaned dataset, after cleaning — what /retrain trains on
│   │   ├── malaria_control_africa_train_data.csv     # the actual 80% train split used to fit every model
│   │   ├── malaria_control_africa_test_data.csv      # the actual 20% held-out test split
│   │   └── model.pkl, scaler.pkl                     # the saved best-performing model and its fitted scaler
│   │
│   ├── api/                     # the FastAPI backend, deployed to Render
│   │   ├── main.py              # app entry point
│   │   ├── routers/             # /predictions/ and /retrain/ endpoint definitions
│   │   ├── schemas/             # Pydantic request/response models — datatypes + range constraints
│   │   ├── services/            # prediction and retraining logic
│   │   ├── runner/               # loads the model, scaler, and SHAP explainer once at startup
│   │   ├── middlewares/         # CORS configuration
│   │   └── requirements.txt     # pinned dependencies for the Render deployment
│   │
│   └── predictionmodel/         # the Flutter mobile app
│       ├── lib/
│       │   ├── main.dart        # app entry point
│       │   ├── models/          # field configuration + request/response types
│       │   ├── screens/         # the single prediction screen
│       │   ├── services/        # the HTTP call to the deployed API
│       │   ├── theme/           # colors and typography
│       │   └── widgets/         # reusable UI pieces — input fields, Predict button, result card
│       ├── test/                # widget test
│       └── android/ ios/ web/ … # platform scaffolding, auto-generated by Flutter
```

---

## Running the Mobile App

The Flutter app lives at `summative/predictionmodel/`. It's a **mobile app** (Android/iOS).
Prerequisites: Dart and Flutter already installed.

```bash
git clone https://github.com/BodeMurairi2/linear_regression_model.git
cd linear_regression_model/summative/predictionmodel
flutter pub get
flutter run   # with a device or emulator connected
```

The API base URL is already hardcoded to the live Render deployment — no configuration is needed to run it.

---

## Retraining Scope

`POST /retrain/` is a manual, on-demand endpoint: submit new labeled data, and the model retrains immediately. The retraining endpoint is intentionally manual: new labeled data must first be obtained and prepared through the data acquisition and cleaning pipeline.

**Deployment note:** Retraining persists the updated model and scaler to disk and reloads them into the running FastAPI process. 

---

## Limitations

- **Population-level, not individual-level** — the model estimates national malaria burden from country-year aggregates; it does not predict any individual's personal risk.
- **Association, not causation** — the relationships the model learns are correlational. They do not establish that changing one factor, such as health spending, would causally change malaria incidence.
- **Random split, not a test of unseen countries** — the 80/20 split evaluates generalization across country-year observations, not the model's ability to generalize to a country it has never seen at all nor to predict future yearly malaria numbers. It only predicts what the number of malaria cases can be based on social, economic, and health factors.
- **Interpolation introduces uncertainty** — features filled by within-country linear interpolation are estimates, not directly observed values, and carry some uncertainty through creating a new linear relationship between data.
- **A decision-support tool, not a replacement for epidemiological expertise** — intended to help see ideal situations to minimize malaria cases, not to replace clinical or public-health judgment.

---

## Video Demo
https://youtu.be/rpgsq1ZJQqE
---

## Sources

### Data Sources
- WHO Global Health Observatory — `MALARIA_EST_INCIDENCE`: https://ghoapi.azureedge.net/api/MALARIA_EST_INCIDENCE
- World Bank Open Data — World Development Indicators: https://api.worldbank.org/v2/country/{iso3-codes}/indicator/{code}

### References
- Weed, L., Lok, R., Chawra, D., & Zeitzer, J. (2022). *The Impact of Missing Data and Imputation Methods on the Analysis of 24-Hour Activity Patterns.* PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC9590093/ — linear interpolation's bias grows with the length of the missing-data gap, part of the basis for excluding Djibouti and Somalia rather than interpolating them.
- Noor, N. M., Abdullah, M. M. A. B., Yahaya, A. S., & Ramli, N. A. (2014). *Comparison of Linear Interpolation Method and Mean Method to Replace the Missing Values in Environmental Data Set.* Materials Science Forum, 803, 278–281. https://www.researchgate.net/publication/271978892 — a direct precedent for comparing linear interpolation against a global mean fill, the same comparison used in this project's cleaning step.
- Thongsripong, P., Hyman, J. M., Kapan, D. D., & Bennett, S. N. (2021). *Human–Mosquito Contact: A Missing Link in Our Understanding of Mosquito-Borne Disease Transmission Dynamics.* Annals of the Entomological Society of America, 114(4), 397–414. https://academic.oup.com/aesa/article/114/4/397/6273070 — basis for keeping `population_density` over `population_total`: transmission depends on human–mosquito contact rate, which density proxies more directly than a raw population count.

### Technical Documentation
- FastAPI: https://fastapi.tiangolo.com/
- Pydantic: https://docs.pydantic.dev/
- SHAP: https://shap.readthedocs.io/
- Flutter: https://docs.flutter.dev/

---

## Author

**Bode Murairi**

**Email: b.murairi@alustudent.com**

**Github: BodeMurairi2**

## Links

- **Backend API:** https://malaria-prevalence.onrender.com
- **Video demo:** https://youtu.be/rpgsq1ZJQqE
