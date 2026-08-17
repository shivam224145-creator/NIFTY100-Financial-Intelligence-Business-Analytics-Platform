-- Add columns to fact tables

ALTER TABLE fact_cash_flow
ADD COLUMN IF NOT EXISTS cash_conversion_ratio NUMERIC;

ALTER TABLE fact_profit_loss
ADD COLUMN IF NOT EXISTS asset_turnover NUMERIC,
ADD COLUMN IF NOT EXISTS return_on_assets NUMERIC;

ALTER TABLE fact_balance_sheet
ADD COLUMN IF NOT EXISTS equity_ratio NUMERIC;


-- Update cash conversion ratio

UPDATE fact_cash_flow cf
SET cash_conversion_ratio =
    CASE
        WHEN p.net_profit = 0 THEN NULL
        ELSE cf.operating_activity / p.net_profit
    END
FROM fact_profit_loss p
WHERE cf.symbol = p.symbol
AND cf.year_id = p.year_id;


-- Update asset turnover and ROA

UPDATE fact_profit_loss p
SET
    asset_turnover =
        CASE
            WHEN b.total_assets = 0 THEN NULL
            ELSE p.sales / b.total_assets
        END,
    return_on_assets =
        CASE
            WHEN b.total_assets = 0 THEN NULL
            ELSE (p.net_profit / b.total_assets) * 100
        END
FROM fact_balance_sheet b
WHERE p.symbol = b.symbol
AND p.year_id = b.year_id;


-- Update equity ratio

UPDATE fact_balance_sheet
SET equity_ratio =
    CASE
        WHEN total_assets = 0 THEN NULL
        ELSE (equity_capital + reserves) / total_assets
    END;


-- Cross-checks --
SELECT
    COUNT(cash_conversion_ratio) AS cash_conversion_not_null
FROM fact_cash_flow;


SELECT
    COUNT(asset_turnover) AS asset_turnover_not_null,
    COUNT(return_on_assets) AS roa_not_null
FROM fact_profit_loss;


SELECT
    COUNT(equity_ratio) AS equity_ratio_not_null
FROM fact_balance_sheet;


-- final formula validation
SELECT
    cf.symbol,
    cf.year_id,
    cf.operating_activity,
    p.net_profit,
    cf.cash_conversion_ratio
FROM fact_cash_flow cf
JOIN fact_profit_loss p
ON cf.symbol = p.symbol
AND cf.year_id = p.year_id
WHERE cf.cash_conversion_ratio IS NOT NULL
LIMIT 10;



SELECT
    p.symbol,
    p.year_id,
    p.sales,
    b.total_assets,
    p.asset_turnover,
    p.return_on_assets
FROM fact_profit_loss p
JOIN fact_balance_sheet b
ON p.symbol = b.symbol
AND p.year_id = b.year_id
WHERE p.asset_turnover IS NOT NULL
LIMIT 10;