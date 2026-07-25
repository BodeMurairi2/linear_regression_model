#!/usr/bin/env python3

import time
import logging
import requests
import pandas as pd
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

session = requests.Session()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)

AFRICA_ISO3 = [
        "DZA", "AGO", "BEN", "BWA", "BFA", "BDI", "CPV", "CMR", "CAF", "TCD", "COM", "COD", "COG",
        "CIV", "DJI", "EGY", "GNQ", "ERI", "SWZ", "ETH", "GAB", "GMB", "GHA", "GIN", "GNB", "KEN",
        "LSO", "LBR", "LBY", "MDG", "MWI", "MLI", "MRT", "MUS", "MAR", "MOZ", "NAM", "NER", "NGA",
        "RWA", "STP", "SEN", "SYC", "SLE", "SOM", "ZAF", "SSD", "SDN", "TZA", "TGO", "TUN", "UGA",
        "ZMB", "ZWE",
        ]

def download_malaria_prevalence():
    """
    This function downloads Malaria incidence dataset from
    WHO in Africa
    """
    url_endpoint = "https://ghoapi.azureedge.net/api/MALARIA_EST_INCIDENCE"

    # filter only for African countries server side
    country_filter = ",".join(f"'{code}'" for code in AFRICA_ISO3) 
    params = {
        "$filter":f"SpatialDimType eq 'COUNTRY' and SpatialDim in ({country_filter})"
    }

    logger.info("Fetching WHO malaria incidence data...")
    response = session.get(url_endpoint, params=params, timeout=30)

    response.raise_for_status()

    logger.info("WHO malaria incidence data fetched successfully.")
    return response.json()

def download_wb_african_indicators():
    """
    This functions download all the features data for our studies
    """
    DATE_RANGE = "2000:2024"
    world_bank_indicators = [
        "SH.XPD.CHEX.PC.CD", "SP.RUR.TOTL.ZS", "NY.GDP.PCAP.CD", "SP.POP.TOTL",
        "AG.LND.FRST.ZS", "EN.POP.DNST", "SH.DYN.MORT", "SP.DYN.LE00.IN",
        "SH.H2O.BASW.ZS", "SP.URB.TOTL.IN.ZS", "SH.XPD.GHED.GD.ZS",
        "SE.PRM.CMPT.ZS", "SP.DYN.TFRT.IN",
        ]

    country_codes = ";".join(AFRICA_ISO3)

    def fetch_indicator(code, retries=4):
        endpoint_url = f"https://api.worldbank.org/v2/country/{country_codes}/indicator/{code}"
        params = {
            "date":DATE_RANGE,
            "format":"json",
            "per_page":20000
        }
        last_error = None
        for attempt in range(retries):
            try:
                response = session.get(endpoint_url, params=params, timeout=30)
                response.raise_for_status()
                return code, response.json()
            except requests.exceptions.RequestException as error:
                last_error = error
                time.sleep(2 + attempt * 2)
        raise last_error

    total = len(world_bank_indicators)
    logger.info(f"Fetching {total} World Bank indicators (5 at a time)...")

    worldbank_data = {}
    completed = 0
    with ThreadPoolExecutor(max_workers=5) as executor:
        futures = {executor.submit(fetch_indicator, code): code for code in world_bank_indicators}
        for future in as_completed(futures):
            code, data = future.result()
            worldbank_data[code] = data
            completed += 1
            logger.info(f"  [{completed}/{total}] fetched {code}")

    logger.info("All World Bank indicators fetched successfully.")
    return worldbank_data

def extract_malaria_data_raw_json(raw_data):
    """
    Extract iso3, year, and malaria incidence value
    from the raw WHO GHO response -dropping all metadata fields
    """
    records = [{
        "iso3": item["SpatialDim"],
        "year": item["TimeDim"],
        "malaria_incidence_per_1000_at_risk": item["NumericValue"]
    }
    for item in raw_data["value"]
    ]
    return pd.DataFrame(records)

def extract_worldbank_data(raw_data):
    """
    Extract iso3, year, and value for each of the 13 World Bank Indicators
    then merge them into a single wide table (one row per country-year
    )"""
    indicator_names = {
        "SH.XPD.CHEX.PC.CD": "health_expenditure_per_capita_usd",
        "SP.RUR.TOTL.ZS": "rural_population_pct",
        "NY.GDP.PCAP.CD": "gdp_per_capita_usd",
        "SP.POP.TOTL": "population_total",
        "AG.LND.FRST.ZS": "forest_area_pct",
        "EN.POP.DNST": "population_density",
        "SH.DYN.MORT": "under5_mortality_per_1000",
        "SP.DYN.LE00.IN": "life_expectancy_years",
        "SH.H2O.BASW.ZS": "basic_water_access_pct",
        "SP.URB.TOTL.IN.ZS": "urban_population_pct",
        "SH.XPD.GHED.GD.ZS": "govt_health_exp_pct_gdp",
        "SE.PRM.CMPT.ZS": "primary_completion_rate_pct",
        "SP.DYN.TFRT.IN": "fertility_rate_births_per_woman",
    }
    merged = None
    country_names = {}
    for code, column_name in indicator_names.items():
        records = raw_data[code][1] or []
        for record in records:
            if record["value"] is not None:
                country_names[record["countryiso3code"]] = record["country"]["value"]
        data = pd.DataFrame([
            {
                "iso3": record["countryiso3code"],
                "year": int(record["date"]),
                column_name: record["value"],
            }
            for record in records
            if record["value"] is not None
        ])
        merged = data if merged is None else merged.merge(data, on=["iso3", "year"], how="outer")
    merged["country"] = merged["iso3"].map(country_names)
    return merged

if __name__ == "__main__":
    save_path = Path(__file__).parent
    malaria_data = download_malaria_prevalence()
    worldbank_data = download_wb_african_indicators()

    malaria_dataframe = extract_malaria_data_raw_json(raw_data=malaria_data)
    worldbank_dataframe = extract_worldbank_data(raw_data=worldbank_data)

    malaria_dataframe.to_csv(f"{save_path}/who_malaria_incidence_raw.csv", index=False)
    worldbank_dataframe.to_csv(f"{save_path}/worldbank_indicators_raw.csv", index=False)
    logger.info(f"Saved who_malaria_incidence_raw.csv ({malaria_dataframe.shape[0]} rows)")
    logger.info(f"Saved worldbank_indicators_raw.csv ({worldbank_dataframe.shape[0]} rows)")
