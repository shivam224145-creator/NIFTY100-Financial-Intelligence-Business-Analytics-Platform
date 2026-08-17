-- Data Quality Validation --
-- Duplicate Check --

-- 1 — fact_profit_loss Duplicate Check
SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_profit_loss
GROUP BY symbol, year_id
HAVING COUNT(*) > 1;


SELECT *
FROM fact_profit_loss
WHERE symbol = 'ADANIPORTS'
ORDER BY year_id;


DELETE FROM fact_profit_loss
WHERE ctid NOT IN (

    SELECT MIN(ctid)

    FROM fact_profit_loss

    GROUP BY symbol, year_id
);


SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_profit_loss
GROUP BY symbol, year_id
HAVING COUNT(*) > 1;


-- 2 — fact_balance_sheet Duplicate Check
SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_balance_sheet
GROUP BY symbol, year_id
HAVING COUNT(*) > 1;


DELETE FROM fact_balance_sheet
WHERE ctid NOT IN (

    SELECT MIN(ctid)

    FROM fact_balance_sheet

    GROUP BY symbol, year_id
);


SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_balance_sheet
GROUP BY symbol, year_id
HAVING COUNT(*) > 1;

-- 3 — fact_cash_flow Duplicate Check
SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_cash_flow
GROUP BY symbol, year_id
HAVING COUNT(*) > 1;


DELETE FROM fact_cash_flow
WHERE ctid NOT IN (

    SELECT MIN(ctid)

    FROM fact_cash_flow

    GROUP BY symbol, year_id
);


SELECT
    symbol,
    year_id,
    COUNT(*)
FROM fact_cash_flow
GROUP BY symbol, year_id
HAVING COUNT(*) > 1

-- 4 — fact_analysis Duplicate Check
SELECT
    symbol,
    period_label,
    COUNT(*)
FROM fact_analysis
GROUP BY symbol, period_label
HAVING COUNT(*) > 1;


-- 5 — fact_pros_cons Duplicate Check
SELECT
    symbol,
    insight_text,
    COUNT(*)
FROM fact_pros_cons
GROUP BY symbol, insight_text
HAVING COUNT(*) > 1;