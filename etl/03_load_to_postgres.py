# ============================================
# NIFTY100 POSTGRES WAREHOUSE LOADER
# ============================================

import pandas as pd
from pathlib import Path
from sqlalchemy import create_engine, text


# ============================================
# PATHS
# ============================================

BASE_DIR = Path(r"C:/Users/LENOVO/Desktop/nifty100_project")
CLEAN_DIR = BASE_DIR / "data" / "clean"


# ============================================
# DATABASE CONFIG
# ============================================

import os

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "YOUR_PASSWORD")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "nifty100_analysis")

engine = create_engine(
    f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


# ============================================
# CLEAN FILE CONFIG
# ============================================

clean_files = {
    "companies": "companies_clean.csv",
    "updated_companies": "updated_companies_clean.csv",
    "analysis": "analysis_clean.csv",
    "balancesheet": "balancesheet_clean.csv",
    "cashflow": "cashflow_clean.csv",
    "profitloss": "profit_clean.csv",
    "prosandcons_clean": "prosandcons_clean.csv",
    "sector_mapping": "sector_mapping.csv",
    "company_updated_health_scores": "company_updated_health_scores.csv",
    "fact_ml_scores": "fact_ml_scores.csv",
    "company_sector_intelligence": "company_sector_intelligence.csv"
}


# ============================================
# VALIDATE CLEAN FILES
# ============================================

def validate_clean_files():
    print("Validating clean files...")
    print("-" * 60)

    for name, file_name in clean_files.items():
        file_path = CLEAN_DIR / file_name

        if file_path.exists():
            df = pd.read_csv(file_path)
            print(f"{file_name} -> {df.shape}")
        else:
            print(f"Missing file: {file_name}")

    print("-" * 60)
    print("Clean file validation completed.")


# ============================================
# LOAD CSV TO POSTGRES
# ============================================

def load_csv_to_table(file_name, table_name, if_exists="append"):
    file_path = CLEAN_DIR / file_name

    if not file_path.exists():
        print(f"Skipped: {file_name} not found.")
        return

    df = pd.read_csv(file_path)

    df.to_sql(
        table_name,
        engine,
        if_exists=if_exists,
        index=False
    )

    print(f"Loaded {file_name} into {table_name} -> {df.shape}")


# ============================================
# LOAD REFERENCE TABLES
# ============================================

def load_reference_tables():
    print("Loading reference tables...")
    print("-" * 60)

    load_csv_to_table(
        "sector_mapping.csv",
        "sector_mapping",
        if_exists="replace"
    )

    load_csv_to_table(
        "company_updated_health_scores.csv",
        "company_updated_health_scores",
        if_exists="replace"
    )

    load_csv_to_table(
        "company_sector_intelligence.csv",
        "company_sector_intelligence",
        if_exists="replace"
    )

    print("-" * 60)
    print("Reference tables loaded successfully.")


# ============================================
# LOAD FACT ML SCORES
# ============================================

def load_fact_ml_scores():
    print("Loading fact_ml_scores...")
    print("-" * 60)

    df = pd.read_csv(CLEAN_DIR / "fact_ml_scores.csv")

    with engine.begin() as conn:
        conn.execute(text("TRUNCATE TABLE fact_ml_scores RESTART IDENTITY;"))

    df.to_sql(
        "fact_ml_scores",
        engine,
        if_exists="append",
        index=False
    )

    print(f"fact_ml_scores loaded successfully -> {df.shape}")


# ============================================
# DATA QUALITY CHECKS
# ============================================

def run_quality_checks():
    print("Running warehouse quality checks...")
    print("-" * 60)

    checks = {
        "fact_ml_scores_count": "SELECT COUNT(*) FROM fact_ml_scores;",
        "sector_mapping_count": "SELECT COUNT(*) FROM sector_mapping;",
        "company_sector_intelligence_count": "SELECT COUNT(*) FROM company_sector_intelligence;"
    }

    with engine.connect() as conn:
        for check_name, query in checks.items():
            result = conn.execute(text(query)).scalar()
            print(f"{check_name}: {result}")

    print("-" * 60)
    print("Quality checks completed.")


# ============================================
# MAIN PIPELINE
# ============================================

def run_postgres_loader():
    print("Starting PostgreSQL Warehouse Loader...")
    print("=" * 60)

    validate_clean_files()

    print("\n")

    load_reference_tables()

    print("\n")

    load_fact_ml_scores()

    print("\n")

    run_quality_checks()

    print("=" * 60)
    print("PostgreSQL warehouse loading completed successfully.")


if __name__ == "__main__":
    run_postgres_loader()

