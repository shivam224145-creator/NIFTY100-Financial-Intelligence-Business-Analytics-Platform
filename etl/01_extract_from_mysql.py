

# ============================================
# NIFTY100 EXTRACTION LAYER
# ============================================

# NOTE:
# This extraction layer currently reads structured Excel exports
# generated from the original MariaDB/MySQL source dump.
#
# In the production environment, this module can be extended
# to parse raw SQL dump files directly using regex-based
# INSERT statement extraction logic as specified in the
# original capstone project requirements.
#
# Current implementation focuses on:
# - structured Excel ingestion
# - production-ready dataframe extraction
# - clean ETL pipeline compatibility
# - downstream warehouse integration

import pandas as pd

from pathlib import Path


# ============================================
# PATHS
# ============================================

BASE_DIR = Path(r"C:/Users/LENOVO/Desktop/nifty100_project")

RAW_DIR = BASE_DIR / "data" / "raw"


# ============================================
# RAW FILE CONFIG
# ============================================

RAW_FILES = {

    "companies": "companies.xlsx",

    "balancesheet": "balancesheet.xlsx",

    "cashflow": "cashflow.xlsx",

    "analysis": "analysis.xlsx",

    "profitandloss": "profitandloss.xlsx",

    "prosandcons": "prosandcons.xlsx"
}


# ============================================
# EXTRACTION FUNCTION
# ============================================

def load_excel_file(file_path, header_row=1):

    df = pd.read_excel(
        file_path,
        header=header_row
    )

    print(f"Loaded: {file_path.name} -> {df.shape}")

    return df


# ============================================
# EXTRACTION PIPELINE
# ============================================

def run_extraction_pipeline():

    print("Starting Extraction Pipeline...")
    print("-" * 60)

    raw_data = {}

    for table_name, file_name in RAW_FILES.items():

        file_path = RAW_DIR / file_name

        # prosandcons special case
        if table_name == "prosandcons":

            df = pd.read_excel(
                file_path,
                header=0
            )

        else:

            df = load_excel_file(
                file_path,
                header_row=1
            )

        raw_data[table_name] = df

    print("-" * 60)

    print("Extraction completed successfully.")

    return raw_data


if __name__ == "__main__":

    run_extraction_pipeline()

