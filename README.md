# Malaria Prevalence Estimator

## Mission

Malaria has been one of the diseases that many african countries have suffered and had a detrimental impact on the healthcare and social life in Africa. In this assignment, my mission is to estimates a country's malaria burden (cases per 1,000 population at risk) from socioeconomic and health-system indicators — GDP, health spending, water access, education — across 52 African countries, 2000–2024.
This is population-level regression, not individual risk prediction: it flags where a country's malaria burden looks high or low relative to peers with similar conditions, supporting surveillance and policy prioritization.
The model goal is to identify where is the overall best social, economic, and health conditions to reduce cases of malaria in Africa and can be used to draft policy recommendations in African countries.
---

## Data Source

The final dataset malaria_control_africa.csv does not currently exist anywhere. It is assembled from two indenpent and public organizations: The World Health Organization and the World Bank. The two data sources used come from live APIs from the World Health Organization and the World Bank Indicators public APIs portals, merged programmatically, not synthetic; every value traces back to an official statistic published by WHO or the World Bank.
the script.py shows step by step how the two raw data sources where acquired.

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
3. **Merge sources** — the WHO table is inner-joined to the World Bank table on `(iso3, year)`, then explicitly sorted alphabetically by country and ascending by year, producing `malaria_control_africa.csv` (1,226 rows, kept on disk untouched as a raw before/after reference).
4. **Handle missing data** — `primary_completion_rate_pct` was ~40% missing. A global mean fill was tested and rejected: it weakened its correlation with the target from −0.563 to −0.460 (an 18% distortion). Within-country linear interpolation was used instead, preserving the correlation almost exactly (−0.550, only 0.013 off).
5. **Drop unrecoverable rows** — Djibouti and Somalia have zero data for `primary_completion_rate_pct` across the entire 25-year span, so interpolation had nothing to interpolate between and would have fabricated a trend from nothing. Both countries were excluded rather than faked.
6. **Feature selection** — `iso3`/`country` (identifiers), `urban_population_pct` (perfect −1.00 collinearity with `rural_population_pct`, the complement kept for its more direct epidemiological relevance), `population_total` (near-zero correlation with the target; `population_density` is the better proxy for mosquito–human contact rate), and `year` (the model is about socioeconomic/health drivers, not a time trend) were all dropped.
7. **Output** — the cleaned, standardization-ready data (11 features + target, 1,176 rows, 52 countries) is saved separately as `clean_malaria_control_africa.csv`, kept apart from the raw file so the "before" and "after" of the cleaning pipeline are both inspectable.

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

**Random Forest was selected as the best-performing model.** It wins on Test RMSE and Test R²; Decision Tree edges it narrowly on Test MAE (23.23 vs. 24.14), but since RMSE penalizes large errors more heavily than MAE, Random Forest's advantage there indicates it handles bigger deviations and outlier countries more robustly — the more practically important property for a screening tool. OLS and SGD converge to essentially the same linear solution and only capture ~58% of the variance, confirming the true relationship between these features and malaria incidence is non-linear — exactly what the tree-based models were able to exploit.

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
Accepts new labeled rows (the 11 features plus the true `malaria_incidence_per_1000_at_risk`), retrains a fresh Random Forest in the background on the combined dataset, and updates the live model in memory immediately — no server restart needed. `GET /retrain/status` reports progress and the last result.
---

## CORS Configuration

```python
allow_origins=["http://localhost:3000", "http://127.0.0.1:3000", "http://localhost:5000", "http://127.0.0.1:5000"]
allow_credentials=False
allow_methods=["GET", "POST"]
allow_headers=["Content-Type"]
```

Each setting was chosen deliberately, not left at a permissive default:
- **Methods** are limited to `GET`/`POST` — the API only reads status and makes predictions; there's nothing to partially edit or to remove `PUT` or `DELETE`.
- **Credentials** are disabled — this is a stateless prediction API with no cookie- or session-based authentication, so there's nothing to carry across origins.
- **Origins** are scoped to local development ports rather than a wildcard, since there is no deployed web frontend for this API — the Flutter mobile app is not subject to CORS at all (CORS only restricts browser-based requests), so the restrictive origin list costs nothing in practice while still avoiding an open `*`.

---

## Repository Structure

```
linear_regression_model/
├── README.md                    # this file
├── pyproject.toml, uv.lock      # Python dependency management (uv)
├── requirements.txt             # pinned dependencies for render
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
│   │   ├── runner/              # loads the model, scaler, and SHAP explainer once at startup
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
Prerequisities: Dart and Flutter already installed.

```bash
git clone https://github.com/BodeMurairi2/linear_regression_model.git
cd linear_regresssion/summative/predictionmodel
flutter pub get
flutter run   # with a device or emulator connected
```

The API base URL is already hardcoded to the live Render deployment — no configuration is needed to run it.

---

## Retraining Scope

`POST /retrain/` is a manual, on-demand endpoint: submit new labeled data, and the model retrains and updates live immediately. It is intentionally **not** a fully automated pipeline that polls WHO/World Bank for new data on its own, for two concrete reasons:

1. **Real automation wouldn't actually remove the manual step.** Even a scheduled job would only be reacting to data that is already sitting somewhere accessible — getting fresh data into that location still requires someone to run the fetch-and-clean pipeline against the WHO/World Bank APIs by hand. Automation here would just move the manual step earlier in the chain, not eliminate it.
2. **Render's free tier has no persistent worker process** to host a scheduler or webhook listener reliably — the service can spin down when idle, which would make a "background polling" feature silently unreliable rather than genuinely automated.

Given both, a manual retrain endpoint is the honest, correctly-scoped implementation for this deployment — reactive to a person's decision that new data exists, functional, and verified to take effect without a restart.

---

## Video Demo

[Video link placeholder — to be added]

---

## Sources Used

- Weed, L., Lok, R., Chawra, D., & Zeitzer, J. (2022). *The Impact of Missing Data and Imputation Methods on the Analysis of 24-Hour Activity Patterns.* PMC. https://pmc.ncbi.nlm.nih.gov/articles/PMC9590093/ — linear interpolation's bias grows with the length of the missing-data gap, which is why Djibouti and Somalia (100% missing) were dropped rather than interpolated.
- Noor, N. M., Abdullah, M. M. A. B., Yahaya, A. S., & Ramli, N. A. (2014). *Comparison of Linear Interpolation Method and Mean Method to Replace the Missing Values in Environmental Data Set.* Materials Science Forum, 803, 278–281. https://www.researchgate.net/publication/271978892 — the direct precedent for comparing linear interpolation against a global mean fill, the same methodology used in this project's own cleaning step.
- Thongsripong, P., Hyman, J. M., Kapan, D. D., & Bennett, S. N. (2021). *Human–Mosquito Contact: A Missing Link in Our Understanding of Mosquito-Borne Disease Transmission Dynamics.* Annals of the Entomological Society of America, 114(4), 397–414. https://academic.oup.com/aesa/article/114/4/397/6273070 — the basis for keeping `population_density` over `population_total`: transmission depends on human–mosquito contact rate, which density proxies far better than a raw population count.

---

## Author

**Bode Murairi**
**Email: b.murairi@alustudent.com**
**Github: BodeMurairi2**

## Links

- **Backend API:** https://malaria-prevalence.onrender.com
- **Video demo:** [placeholder — to be added]
