-------------- dim_company ------------
CREATE TABLE dim_company (
    symbol VARCHAR(20) PRIMARY KEY,
    company_name TEXT,
    sector TEXT,
    sub_sector TEXT,
    company_logo TEXT,
    website TEXT,
    nse_url TEXT,
    bse_url TEXT,
    face_value NUMERIC,
    book_value NUMERIC,
    about_company TEXT
);
select * from dim_company

-- Data insert (existing in clean table)
INSERT INTO dim_company (
    symbol,
    company_name,
    sector,
    sub_sector,
    company_logo,
    website,
    nse_url,
    bse_url,
    face_value,
    book_value,
    about_company
)
SELECT 
    symbol,
    company_name,
    sector,
    sub_sector,
    company_logo,
    website,
    nse_url,
    bse_url,
    face_value,
    book_value,
    about_company
FROM companies;

-- Check
SELECT * FROM dim_company LIMIT 5;

-------------- dim_year ------------

CREATE TABLE dim_year (
    year_id SERIAL PRIMARY KEY,
    year_label VARCHAR(20),
    fiscal_year INT,
    quarter VARCHAR(5),
    is_ttm BOOLEAN,
    is_half_year BOOLEAN,
    sort_order INT
);
select * from dim_year;

-- Data insert
INSERT INTO dim_year (year_label, fiscal_year, quarter, is_ttm, is_half_year, sort_order)
SELECT DISTINCT
    year AS year_label,
    
    CASE 
        WHEN year = 'TTM' THEN NULL
        ELSE CAST(RIGHT(year, 4) AS INT)
    END AS fiscal_year,

    CASE 
        WHEN year LIKE 'Mar%' THEN 'Q4'
        WHEN year LIKE 'Jun%' THEN 'Q1'
        WHEN year LIKE 'Sep%' THEN 'Q2'
        WHEN year LIKE 'Dec%' THEN 'Q3'
        ELSE NULL
    END AS quarter,

    CASE WHEN year = 'TTM' THEN TRUE ELSE FALSE END AS is_ttm,

    FALSE AS is_half_year,

    CASE 
        WHEN year = 'TTM' THEN 9999
        ELSE CAST(RIGHT(year, 4) AS INT)
    END AS sort_order

FROM profitloss;

-- Check
SELECT * FROM dim_year ORDER BY sort_order;

INSERT INTO dim_year (
    year_label,
    fiscal_year,
    quarter,
    is_ttm,
    is_half_year,
    sort_order
)
VALUES (
    'TTM',
    NULL,
    NULL,
    TRUE,
    FALSE,
    9999
);

-- Re-check
SELECT * FROM dim_year ORDER BY sort_order;




-- FACT TABLES CREATION --

-- Create fact_profit_loss --
CREATE TABLE fact_profit_loss (
    
    fact_id SERIAL PRIMARY KEY,

    symbol VARCHAR(20),
    year_id INT,

    sales NUMERIC,
    expenses NUMERIC,
    operating_profit NUMERIC,
    opm_percentage NUMERIC,

    net_profit NUMERIC,
    eps NUMERIC,
    dividend_payout NUMERIC,

    net_profit_margin NUMERIC,
    expense_ratio NUMERIC,
    interest_coverage NUMERIC,

    CONSTRAINT fk_profit_company
        FOREIGN KEY (symbol)
        REFERENCES dim_company(symbol),

    CONSTRAINT fk_profit_year
        FOREIGN KEY (year_id)
        REFERENCES dim_year(year_id)

);
SELECT * FROM fact_profit_loss;


INSERT INTO dim_company (
    symbol,
    company_name
)

SELECT DISTINCT
    p.symbol,
    p.symbol

FROM profitloss p

LEFT JOIN dim_company d
ON p.symbol = d.symbol

WHERE d.symbol IS NULL;


SELECT *
FROM dim_company
WHERE symbol IN (
'UNITDSPR',
'ZOMATO',
'ZYDUSLIFE',
'ULTRACEMCO',
'WIPRO',
'VEDL',
'UNIONBANK'
);
-- LOAD DATA INTO fact_profit_loss
-- INSERT DATA
INSERT INTO fact_profit_loss (

    symbol,
    year_id,
    sales,
    expenses,
    operating_profit,
    opm_percentage,
    net_profit,
    eps,
    dividend_payout,
    net_profit_margin,
    expense_ratio,
    interest_coverage

)

SELECT

    p.symbol,
    y.year_id,
    p.sales,
    p.expenses,
    p.operating_profit,
    p.opm_percentage,
    p.net_profit,
    p.eps,
    p.dividend_payout,
    p.net_profit_margin,
    p.expense_ratio,
    p.interest_coverage

FROM profitloss p

JOIN dim_year y
ON p.year = y.year_label;


-- CROSS CHECKS-
SELECT COUNT(*) 
FROM fact_profit_loss;

SELECT *
FROM fact_profit_loss
LIMIT 5;




-- FACT BALANCE CREATION --
-- CREATE TABLE --
CREATE TABLE fact_balance_sheet (

    fact_id SERIAL PRIMARY KEY,

    symbol VARCHAR(20),
    year_id INT,

    equity_capital NUMERIC,
    reserves NUMERIC,
    borrowings NUMERIC,
    other_liabilities NUMERIC,
    total_liabilities NUMERIC,

    fixed_assets NUMERIC,
    cwip NUMERIC,
    investments NUMERIC,
    other_assets NUMERIC,
    total_assets NUMERIC,

    debt_to_equity NUMERIC,

    CONSTRAINT fk_balance_company
        FOREIGN KEY (symbol)
        REFERENCES dim_company(symbol),

    CONSTRAINT fk_balance_year
        FOREIGN KEY (year_id)
        REFERENCES dim_year(year_id)

);
SELECT * FROM fact_balance_sheet;


-- LOAD DATA --
INSERT INTO fact_balance_sheet (

    symbol,
    year_id,
    equity_capital,
    reserves,
    borrowings,
    other_liabilities,
    total_liabilities,
    fixed_assets,
    cwip,
    investments,
    other_assets,
    total_assets,
    debt_to_equity

)

SELECT

    b.symbol,
    y.year_id,
    b.equity_capital,
    b.reserves,
    b.borrowings,
    b.other_liabilities,
    b.total_liabilities,
    b.fixed_assets,
    b.cwip,
    b.investments,
    b.other_assets,
    b.total_assets,
    b.debt_to_equity

FROM balancesheet b

JOIN dim_year y
ON b.year = y.year_label;

-- CROSS CHECK --
SELECT COUNT(*)
FROM fact_balance_sheet;

SELECT *
FROM fact_balance_sheet
LIMIT 5;



-- FACT CASHFLOW CREATION --
-- CREATE TABLE --
CREATE TABLE fact_cash_flow (
    cashflow_id SERIAL PRIMARY KEY,
    symbol VARCHAR(20),
    year_id INT,

    operating_activity NUMERIC,
    investing_activity NUMERIC,
    financing_activity NUMERIC,
    net_cash_flow NUMERIC,
    free_cash_flow NUMERIC,

    CONSTRAINT fk_cashflow_company
        FOREIGN KEY(symbol)
        REFERENCES dim_company(symbol),

    CONSTRAINT fk_cashflow_year
        FOREIGN KEY(year_id)
        REFERENCES dim_year(year_id)
);
SELECT * FROM fact_cash_flow;


-- LOAD DATA --
INSERT INTO fact_cash_flow (
    symbol,
    year_id,
    operating_activity,
    investing_activity,
    financing_activity,
    net_cash_flow,
    free_cash_flow
)

SELECT
    c.symbol,
    y.year_id,

    cf.operating_activity,
    cf.investing_activity,
    cf.financing_activity,
    cf.net_cash_flow,

    (cf.operating_activity + cf.investing_activity) AS free_cash_flow

FROM cashflow cf

JOIN dim_company c
ON cf.symbol = c.symbol

JOIN dim_year y
ON cf.year = y.year_label;

-- CROSS CHECK --
SELECT COUNT(*)
FROM fact_cash_flow;

SELECT COUNT(*)
FROM fact_cash_flow
WHERE operating_activity IS NULL;





-- FACT ANALYSIS CREATION --
-- CREATE TABLE --
CREATE TABLE fact_analysis (
    analysis_id SERIAL PRIMARY KEY,

    symbol VARCHAR(20),
    period_label VARCHAR(10),

    compounded_sales_growth_pct NUMERIC,
    compounded_profit_growth_pct NUMERIC,
    stock_price_cagr_pct NUMERIC,
    roe_pct NUMERIC,

    CONSTRAINT fk_analysis_company
        FOREIGN KEY(symbol)
        REFERENCES dim_company(symbol)
);
SELECT * FROM fact_analysis;


-- LOAD DATA --
INSERT INTO fact_analysis (
    symbol,
    period_label,
    compounded_sales_growth_pct,
    compounded_profit_growth_pct,
    stock_price_cagr_pct,
    roe_pct
)

SELECT
    a.symbol,
    a.period,

    a.sales_growth,
    a.profit_growth,
    a.stock_cagr,
    a.roe

FROM analysis a
JOIN dim_company c
ON a.symbol = c.symbol;


-- CROSS CHECK --
SELECT COUNT(*)
FROM fact_analysis;





-- FACT PROSANDCONS CREATION --
-- CREATE TABLE --
CREATE TABLE fact_pros_cons (
    pros_cons_id SERIAL PRIMARY KEY,

    symbol VARCHAR(20),

    is_pro BOOLEAN,
    category VARCHAR(100),
    insight_text TEXT,

    source VARCHAR(50) DEFAULT 'MANUAL',
    confidence NUMERIC DEFAULT 1.0,

    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_proscons_company
        FOREIGN KEY(symbol)
        REFERENCES dim_company(symbol)
);
SELECT * FROM fact_pros_cons;


-- LOAD DATA --
INSERT INTO fact_pros_cons (
    symbol,
    is_pro,
    category,
    insight_text
)

-- PROS
SELECT
    company_id AS symbol,

    TRUE AS is_pro,

    'GENERAL' AS category,

    pros AS insight_text

FROM prosandcons

WHERE pros IS NOT NULL
AND pros <> 'NULL'

UNION ALL

-- CONS
SELECT
    company_id AS symbol,

    FALSE AS is_pro,

    'GENERAL' AS category,

    cons AS insight_text

FROM prosandcons

WHERE cons IS NOT NULL
AND cons <> 'NULL';

-- CROSS CHECK --
SELECT *
FROM fact_pros_cons
LIMIT 10;

SELECT COUNT(*)
FROM fact_pros_cons;

SELECT is_pro, COUNT(*)
FROM fact_pros_cons
GROUP BY is_pro;