-- IMPORTANT CROSS-CHEKS --
SELECT 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;


SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'dim_company'
ORDER BY ordinal_position;


SELECT 
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name = 'company_health_scores';


-- Create dim_sector --
CREATE TABLE IF NOT EXISTS dim_sector (
    sector_id SERIAL PRIMARY KEY,
    sector_name VARCHAR(100) UNIQUE NOT NULL,
    sector_code VARCHAR(20),
    description TEXT
);
SELECT * FROM dim_sector;

-- INSERT DATA --
INSERT INTO dim_sector (
    sector_name,
    sector_code,
    description
)
VALUES
('IT', 'IT', 'Information Technology companies'),
('BANKING', 'BANK', 'Banking and financial institutions'),
('NBFC', 'NBFC', 'Non Banking Financial Companies'),
('INSURANCE', 'INS', 'Insurance companies'),
('ENERGY', 'ENG', 'Energy and oil companies'),
('POWER', 'PWR', 'Power generation and transmission companies'),
('AUTO', 'AUTO', 'Automobile and vehicle manufacturers'),
('PHARMA', 'PHR', 'Pharmaceutical and healthcare companies'),
('FMCG', 'FMCG', 'Fast Moving Consumer Goods companies'),
('CEMENT', 'CEM', 'Cement and infrastructure companies'),
('METALS', 'MET', 'Metal and mining companies'),
('TELECOM', 'TEL', 'Telecommunication companies'),
('CONSUMER GOODS', 'CG', 'Consumer products companies'),
('PORTS', 'PORT', 'Ports and logistics companies'),
('HEALTHCARE', 'HLTH', 'Healthcare and hospital companies'),
('PAINT', 'PNT', 'Paint and coatings companies'),
('HOLDING COMPANY', 'HOLD', 'Investment and holding companies')
ON CONFLICT (sector_name) DO NOTHING;

-- Cross Check
SELECT *
FROM dim_sector
ORDER BY sector_name;

-- Create dim_health_label --
CREATE TABLE IF NOT EXISTS dim_health_label (
    label_id SERIAL PRIMARY KEY,
    label_name VARCHAR(20) UNIQUE NOT NULL,
    min_score NUMERIC,
    max_score NUMERIC,
    color_hex VARCHAR(10)
);
SELECT * FROM dim_health_label;


-- INSERT DATA --
INSERT INTO dim_health_label (
    label_name,
    min_score,
    max_score,
    color_hex
)
VALUES
    ('EXCELLENT', 85, 100, '#008000'),
    ('GOOD', 70, 84, '#32CD32'),
    ('AVERAGE', 55, 69, '#FFA500'),
    ('WEAK', 40, 54, '#FF4500'),
    ('POOR', 0, 39, '#FF0000')
ON CONFLICT (label_name) DO NOTHING;

-- Cross Check
SELECT *
FROM dim_health_label
ORDER BY min_score DESC;



-- Create fact_ml_scores --
CREATE TABLE IF NOT EXISTS fact_ml_scores (
    ml_score_id SERIAL PRIMARY KEY,

    symbol VARCHAR(20),

    computed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    overall_score NUMERIC,

    profitability_score NUMERIC,

    growth_score NUMERIC,

    leverage_score NUMERIC,

    cashflow_score NUMERIC,

    dividend_score NUMERIC,

    trend_score NUMERIC,

    health_label VARCHAR(20),

    CONSTRAINT fk_ml_company
        FOREIGN KEY(symbol)
        REFERENCES dim_company(symbol)
);

-- CROSS CHEKS
SELECT 
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'fact_ml_scores'
ORDER BY ordinal_position;

-- NOW
TRUNCATE TABLE fact_ml_scores RESTART IDENTITY;


-- Row Count Check
SELECT COUNT(*)
FROM fact_ml_scores;

SELECT *
FROM fact_ml_scores
LIMIT 10;

-- Foreign Key Check
SELECT DISTINCT f.symbol
FROM fact_ml_scores f
LEFT JOIN dim_company d
ON f.symbol = d.symbol
WHERE d.symbol IS NULL;

-- Health Label Distribution
SELECT 
    health_label,
    COUNT(*) AS company_count
FROM fact_ml_scores
GROUP BY health_label
ORDER BY company_count DESC;