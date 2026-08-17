
# ============================================
# NIFTY100 ETL CLEAN & TRANSFORM PIPELINE
# ============================================

import pandas as pd
import numpy as np
import re

from pathlib import Path


# ============================================
# PATHS
# ============================================

BASE_DIR = Path(r"C:/Users/LENOVO/Desktop/nifty100_project")

RAW_DIR = BASE_DIR / "data" / "raw"

CLEAN_DIR = BASE_DIR / "data" / "clean"


# ============================================
# HELPER FUNCTIONS
# ============================================

def clean_null_values(df):

    df = df.copy()

    df = df.replace(
        ['NULL', 'Null', 'null', ''],
        np.nan
    )

    return df


def standardize_fiscal_year(year_value):

    if pd.isna(year_value):
        return np.nan

    year_text = str(year_value).strip()

    if year_text.upper() == "TTM":
        return np.nan

    match_4_digit = re.search(r'(\d{4})', year_text)

    if match_4_digit:
        return int(match_4_digit.group(1))

    match_2_digit = re.search(r'(\d{2})$', year_text)

    if match_2_digit:
        return 2000 + int(match_2_digit.group(1))

    return np.nan


def convert_to_numeric(df, columns):

    df = df.copy()

    for col in columns:

        if col in df.columns:

            df[col] = pd.to_numeric(
                df[col],
                errors='coerce'
            )

    return df


# ============================================
# TRANSFORM FUNCTIONS
# ============================================

def transform_analysis(df):

    df = clean_null_values(df)

    cleaned_data = []

    for _, row in df.iterrows():

        period, sales_growth = clean_row_data(
            row['compounded_sales_growth']
        )

        _, profit_growth = clean_row_data(
            row['compounded_profit_growth']
        )

        _, stock_cagr = clean_row_data(
            row['stock_price_cagr']
        )

        _, roe = clean_row_data(
            row['roe']
        )

        cleaned_data.append({

            'symbol': row['company_id'],

            'period': period,

            'sales_growth': sales_growth,

            'profit_growth': profit_growth,

            'stock_cagr': stock_cagr,

            'roe': roe
        })

    return pd.DataFrame(cleaned_data)


def transform_companies(df):

    df = clean_null_values(df)

    df = df.copy()

    df = df.rename(columns={

        'id': 'symbol',

        'nse_profile': 'nse_url',

        'bse_profile': 'bse_url',

        'roce_percentage': 'roce',

        'roe_percentage': 'roe'
    })

    df['company_name'] = (

        df['company_name']
        .astype(str)
        .str.strip()
        .str.replace(r'[\r\n]+', ' ', regex=True)
    )

    df['sector'] = np.nan

    df['sub_sector'] = np.nan

    return df


def transform_balancesheet(df):

    df = clean_null_values(df)

    df = df.copy()

    df = df.rename(columns={

        'company_id': 'symbol',

        'other_asset': 'other_assets'
    })

    df['fiscal_year'] = df['year'].apply(
        standardize_fiscal_year
    )

    numeric_cols = [

        'equity_capital',
        'reserves',
        'borrowings',
        'other_liabilities',
        'total_liabilities',
        'fixed_assets',
        'cwip',
        'investments',
        'other_assets',
        'total_assets'
    ]

    df = convert_to_numeric(df, numeric_cols)

    df['debt_to_equity'] = (

        df['borrowings'] /

        (
            df['equity_capital'] +
            df['reserves']
        )
    )

    return df


def clean_row_data(val):

    if pd.isna(val):
        return None, np.nan

    text = str(val).strip()

    match = re.search(r'^(.*?):\s*(-?\d+)', text)

    if match:

        period_raw = match.group(1).strip()

        value = float(match.group(2))

        if '10' in period_raw:
            period = '10Y'

        elif '5' in period_raw:
            period = '5Y'

        elif '3' in period_raw:
            period = '3Y'

        elif 'TTM' in period_raw.upper():
            period = 'TTM'

        elif '1' in period_raw:
            period = '1Y'

        else:
            period = period_raw

        return period, value

    num_only = re.search(r'(-?\d+)', text)

    return None, float(num_only.group(1)) if num_only else np.nan


def transform_cashflow(df):

    df = clean_null_values(df)

    df = df.copy()

    df = df.rename(columns={
        'company_id': 'symbol'
    })

    df['fiscal_year'] = df['year'].apply(
        standardize_fiscal_year
    )

    numeric_cols = [

        'operating_activity',
        'investing_activity',
        'financing_activity',
        'net_cash_flow'
    ]

    df = convert_to_numeric(df, numeric_cols)

    df['free_cash_flow'] = (

        df['operating_activity'] +

        df['investing_activity']
    )

    df = df.dropna(subset=[

        'operating_activity',
        'investing_activity',
        'financing_activity',
        'net_cash_flow',
        'free_cash_flow'
    ])

    df = df.reset_index(drop=True)

    return df


def transform_profitloss(df):

    df = clean_null_values(df)

    df = df.copy()

    df = df.rename(columns={
        'company_id': 'symbol'
    })

    df['year'] = (
        df['year']
        .astype(str)
        .str.strip()
    )

    df['fiscal_year'] = df['year'].apply(
        standardize_fiscal_year
    )

    numeric_cols = [

        'sales',
        'expenses',
        'operating_profit',
        'opm_percentage',
        'other_income',
        'interest',
        'depreciation',
        'profit_before_tax',
        'tax_percentage',
        'net_profit',
        'eps',
        'dividend_payout'
    ]

    df = convert_to_numeric(df, numeric_cols)

    df['net_profit_margin_pct'] = np.where(

        df['sales'] == 0,

        np.nan,

        (df['net_profit'] / df['sales']) * 100
    )

    df['expense_ratio_pct'] = np.where(

        df['sales'] == 0,

        np.nan,

        (df['expenses'] / df['sales']) * 100
    )

    df['interest_coverage'] = np.where(

        df['interest'] == 0,

        np.nan,

        df['operating_profit'] / df['interest']
    )

    return df


def transform_prosandcons(df):

    df = clean_null_values(df)

    df = df.copy()

    df.columns = df.columns.astype(str).str.strip()

    if 'company_id' in df.columns:
        company_col = 'company_id'

    elif 'company_' in df.columns:
        company_col = 'company_'

    elif 'company' in df.columns:
        company_col = 'company'

    else:
        raise ValueError("Company column not found")

    cleaned_rows = []

    for _, row in df.iterrows():

        symbol = row[company_col]

        if pd.notna(row.get('pros')):

            cleaned_rows.append({

                'symbol': symbol,

                'is_pro': True,

                'category': 'GENERAL',

                'insight_text': str(row['pros']).strip(),

                'source': 'MANUAL',

                'confidence': 1.0
            })

        if pd.notna(row.get('cons')):

            cleaned_rows.append({

                'symbol': symbol,

                'is_pro': False,

                'category': 'GENERAL',

                'insight_text': str(row['cons']).strip(),

                'source': 'MANUAL',

                'confidence': 1.0
            })

    return pd.DataFrame(cleaned_rows)


# ============================================
# MASTER ETL PIPELINE
# ============================================

def load_excel_file(file_path, header_row=1):

    df = pd.read_excel(file_path, header=header_row)

    print(f"Loaded: {file_path.name} -> {df.shape}")

    return df


def run_etl_pipeline():

    print("Starting Nifty100 ETL Pipeline...")
    print("-" * 60)

    raw_files = {

        "companies": "companies.xlsx",

        "balancesheet": "balancesheet.xlsx",

        "cashflow": "cashflow.xlsx",

        "analysis": "analysis.xlsx",

        "profitandloss": "profitandloss.xlsx"
    }

    raw_data = {}

    for table_name, file_name in raw_files.items():

        raw_data[table_name] = load_excel_file(
            RAW_DIR / file_name,
            header_row=1
        )

    # prosandcons current file has header at row 0
    raw_data["prosandcons"] = pd.read_excel(
        RAW_DIR / "prosandcons.xlsx",
        header=0
    )

    print("Extraction completed.")
    print("-" * 60)

    transformed_data = {

        "analysis_clean": transform_analysis(raw_data["analysis"]),

        "companies_clean": transform_companies(raw_data["companies"]),

        "balancesheet_clean": transform_balancesheet(raw_data["balancesheet"]),

        "cashflow_clean": transform_cashflow(raw_data["cashflow"]),

        "prosandcons_clean": transform_prosandcons(raw_data["prosandcons"])
    }

    profit_full = transform_profitloss(raw_data["profitandloss"])

    profit_clean = profit_full[
        profit_full["year"].str.contains("Mar", na=False)
    ]

    profit_clean = profit_clean.dropna(subset=["fiscal_year"])

    profit_clean["fiscal_year"] = profit_clean["fiscal_year"].astype(int)

    profit_clean = profit_clean[[

        "symbol",
        "year",
        "fiscal_year",
        "sales",
        "expenses",
        "operating_profit",
        "opm_percentage",
        "net_profit",
        "eps",
        "dividend_payout",
        "net_profit_margin_pct",
        "expense_ratio_pct",
        "interest_coverage"
    ]]

    profit_clean = profit_clean.reset_index(drop=True)

    transformed_data["profit_clean"] = profit_clean

    print("Transformation completed.")
    print("-" * 60)

    for name, df in transformed_data.items():

        output_path = CLEAN_DIR / f"{name}.csv"

        df.to_csv(output_path, index=False)

        print(f"Saved: {output_path.name} -> {df.shape}")

    print("-" * 60)
    print("ETL Pipeline completed successfully.")

    return transformed_data


if __name__ == "__main__":

    run_etl_pipeline()

# ============================================
# ADVANCED SECTOR ENRICHMENT PIPELINE
# ============================================

def create_sector_mapping():

    sector_mapping = {

        'ABB': ('PHARMA', 'Healthcare'),
        'ADANIENSOL': ('POWER', 'Power Transmission'),
        'ADANIENT': ('ENERGY', 'Diversified Energy'),
        'ADANIGREEN': ('POWER', 'Renewable Energy'),
        'ADANIPORTS': ('PORTS', 'Ports & Logistics'),
        'ADANIPOWER': ('POWER', 'Power Generation'),
        'AMBUJACEM': ('CEMENT', 'Cement'),
        'APOLLOHOSP': ('HEALTHCARE', 'Hospitals'),
        'ASIANPAINT': ('PAINT', 'Paints'),
        'ATGL': ('ENERGY', 'Gas Distribution'),
        'AXISBANK': ('BANKING', 'Private Bank'),
        'BAJAJ-AUTO': ('AUTO', 'Two Wheelers'),
        'BAJAJFINSV': ('NBFC', 'Financial Services'),
        'BAJAJHLDNG': ('HOLDING COMPANY', 'Investment Holding'),
        'BAJFINANCE': ('NBFC', 'Consumer Finance'),
        'BANKBARODA': ('BANKING', 'Public Bank'),
        'BEL': ('DEFENCE', 'Defence Electronics'),
        'BHARTIARTL': ('TELECOM', 'Telecom Services'),
        'BHEL': ('POWER', 'Heavy Electrical Equipment'),
        'BOSCHLTD': ('AUTO', 'Auto Components'),
        'BPCL': ('ENERGY', 'Oil & Gas'),
        'BRITANNIA': ('FMCG', 'Food Products'),
        'CANBK': ('BANKING', 'Public Bank'),
        'CHOLAFIN': ('NBFC', 'Vehicle Finance'),
        'CIPLA': ('PHARMA', 'Pharmaceuticals'),
        'COALINDIA': ('METALS', 'Mining'),
        'DABUR': ('FMCG', 'Consumer Goods'),
        'DIVISLAB': ('PHARMA', 'Pharmaceuticals'),
        'DLF': ('REAL ESTATE', 'Real Estate'),
        'DMART': ('CONSUMER GOODS', 'Retail'),
        'DRREDDY': ('PHARMA', 'Pharmaceuticals'),
        'EICHERMOT': ('AUTO', 'Automobiles'),
        'GAIL': ('ENERGY', 'Gas Utility'),
        'GODREJCP': ('FMCG', 'Consumer Goods'),
        'GRASIM': ('CEMENT', 'Diversified Cement'),
        'HAL': ('DEFENCE', 'Aerospace & Defence'),
        'HAVELLS': ('CONSUMER GOODS', 'Electrical Products'),
        'HCLTECH': ('IT', 'IT Services'),
        'HDFCBANK': ('BANKING', 'Private Bank'),
        'HDFCLIFE': ('INSURANCE', 'Life Insurance'),
        'HEROMOTOCO': ('AUTO', 'Two Wheelers'),
        'HINDALCO': ('METALS', 'Metals'),
        'HINDUNILVR': ('FMCG', 'Consumer Goods'),
        'ICICIBANK': ('BANKING', 'Private Bank'),
        'ICICIGI': ('INSURANCE', 'General Insurance'),
        'ICICIPRULI': ('INSURANCE', 'Life Insurance'),
        'INDIGO': ('AVIATION', 'Airlines'),
        'INDUSINDBK': ('BANKING', 'Private Bank'),
        'INFY': ('IT', 'IT Services'),
        'IOC': ('ENERGY', 'Oil & Gas'),
        'IRCTC': ('TRANSPORT', 'Railway Services'),
        'IRFC': ('NBFC', 'Railway Finance'),
        'ITC': ('FMCG', 'Consumer Goods'),
        'JINDALSTEL': ('METALS', 'Steel'),
        'JIOFIN': ('NBFC', 'Financial Services'),
        'JSWENERGY': ('POWER', 'Power Generation'),
        'JSWSTEEL': ('METALS', 'Steel'),
        'KOTAKBANK': ('BANKING', 'Private Bank'),
        'LICI': ('INSURANCE', 'Life Insurance'),
        'LODHA': ('REAL ESTATE', 'Real Estate'),
        'LT': ('INFRASTRUCTURE', 'Engineering & Construction'),
        'LTIM': ('IT', 'IT Services'),
        'M&M': ('AUTO', 'Automobiles'),
        'MARUTI': ('AUTO', 'Passenger Vehicles'),
        'MOTHERSON': ('AUTO', 'Auto Components'),
        'NAUKRI': ('IT', 'Internet Services'),
        'NESTLEIND': ('FMCG', 'Food Products'),
        'NHPC': ('POWER', 'Hydro Power'),
        'NTPC': ('POWER', 'Power Generation'),
        'ONGC': ('ENERGY', 'Oil Exploration'),
        'PFC': ('NBFC', 'Power Finance'),
        'PIDILITIND': ('CHEMICALS', 'Adhesives'),
        'PNB': ('BANKING', 'Public Bank'),
        'POWERGRID': ('POWER', 'Power Transmission'),
        'RECLTD': ('NBFC', 'Power Finance'),
        'RELIANCE': ('ENERGY', 'Conglomerate'),
        'SBILIFE': ('INSURANCE', 'Life Insurance'),
        'SBIN': ('BANKING', 'Public Bank'),
        'SHREECEM': ('CEMENT', 'Cement'),
        'SHRIRAMFIN': ('NBFC', 'Retail Finance'),
        'SIEMENS': ('INDUSTRIALS', 'Industrial Equipment'),
        'SUNPHARMA': ('PHARMA', 'Pharmaceuticals'),
        'TATACONSUM': ('FMCG', 'Consumer Goods'),
        'TATAMOTORS': ('AUTO', 'Automobiles'),
        'TATAPOWER': ('POWER', 'Power Generation'),
        'TATASTEEL': ('METALS', 'Steel'),
        'TCS': ('IT', 'IT Services'),
        'TECHM': ('IT', 'IT Services'),
        'TITAN': ('CONSUMER GOODS', 'Jewellery & Lifestyle'),
        'TORNTPHARM': ('PHARMA', 'Pharmaceuticals'),
        'TRENT': ('CONSUMER GOODS', 'Retail'),
        'TVSMOTOR': ('AUTO', 'Two Wheelers')
    }

    mapping_df = pd.DataFrame([
        {
            "symbol": symbol,
            "sector": values[0],
            "sub_sector": values[1]
        }
        for symbol, values in sector_mapping.items()
    ])

    return mapping_df


def save_sector_enrichment_files():

    companies_path = CLEAN_DIR / "companies_clean.csv"

    scores_path = CLEAN_DIR / "company_updated_health_scores.csv"

    companies_df = pd.read_csv(companies_path)

    scores_df = pd.read_csv(scores_path)

    sector_mapping_df = create_sector_mapping()

    sector_mapping_df.to_csv(
        CLEAN_DIR / "sector_mapping.csv",
        index=False
    )

    updated_companies_df = companies_df.drop(
        columns=["sector", "sub_sector"],
        errors="ignore"
    )

    updated_companies_df = updated_companies_df.merge(
        sector_mapping_df,
        on="symbol",
        how="left"
    )

    updated_companies_df.to_csv(
        CLEAN_DIR / "updated_companies_clean.csv",
        index=False
    )

    company_sector_intelligence_df = scores_df.merge(
        sector_mapping_df,
        on="symbol",
        how="left"
    )

    company_sector_intelligence_df.to_csv(
        CLEAN_DIR / "company_sector_intelligence.csv",
        index=False
    )

    print("Sector enrichment pipeline completed successfully.")


save_sector_enrichment_files()
