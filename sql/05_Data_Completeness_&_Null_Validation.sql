-- NULL & Data Completeness Validation --

-- Check NULLs in fact_profit_loss--
ALTER TABLE fact_profit_loss

ADD COLUMN net_profit_margin_pct NUMERIC,
ADD COLUMN expense_ratio_pct NUMERIC;



UPDATE fact_profit_loss

SET
net_profit_margin_pct =
    CASE
        WHEN sales = 0 THEN NULL
        ELSE (net_profit * 100.0 / sales)
    END,

expense_ratio_pct =
    CASE
        WHEN sales = 0 THEN NULL
        ELSE (expenses * 100.0 / sales)
    END;



SELECT

    COUNT(*) AS total_rows,

    COUNT(sales) AS sales_not_null,

    COUNT(net_profit) AS profit_not_null,

    COUNT(net_profit_margin_pct) AS margin_not_null,

    COUNT(expense_ratio_pct) AS expense_ratio_not_null,

    COUNT(interest_coverage) AS interest_coverage_not_null

FROM fact_profit_loss;


-- Validate fact_balance_sheet Completeness --
SELECT

    COUNT(*) AS total_rows,

    COUNT(total_assets) AS assets_not_null,

    COUNT(total_liabilities) AS liabilities_not_null,

    COUNT(debt_to_equity) AS debt_equity_not_null

FROM fact_balance_sheet;


-- Validate fact_cash_flow Completeness --
SELECT

    COUNT(*) AS total_rows,

    COUNT(operating_activity) AS operating_not_null,

    COUNT(investing_activity) AS investing_not_null,

    COUNT(financing_activity) AS financing_not_null,

    COUNT(free_cash_flow) AS fcf_not_null

FROM fact_cash_flow;


-- Validate fact_analysis Completeness --
SELECT

    COUNT(*) AS total_rows,

    COUNT(compounded_sales_growth_pct) AS sales_growth_not_null,

    COUNT(compounded_profit_growth_pct) AS profit_growth_not_null,

    COUNT(stock_price_cagr_pct) AS cagr_not_null,

    COUNT(roe_pct) AS roe_not_null

FROM fact_analysis;


-- Validate fact_pros_cons Completeness --
SELECT

    COUNT(*) AS total_rows,

    COUNT(insight_text) AS insight_not_null,

    COUNT(is_pro) AS is_pro_not_null,

    COUNT(source) AS source_not_null,

    COUNT(confidence) AS confidence_not_null

FROM fact_pros_cons;


-- Business Logic Validation --
-- Validate Net Profit Margin Range --
SELECT

    company_name,
    sales,
    net_profit,
    ROUND(net_profit_margin_pct, 2) AS margin_pct

FROM fact_profit_loss f

JOIN dim_company d
ON f.symbol = d.symbol

WHERE net_profit_margin_pct > 100
   OR net_profit_margin_pct < -100

ORDER BY net_profit_margin_pct DESC;


-- Cross-check --
SELECT 
    f.symbol,
    d.company_name,
    f.year_id,
    f.sales,
    f.net_profit,
    f.net_profit_margin_pct
FROM fact_profit_loss f
JOIN dim_company d
ON f.symbol = d.symbol
WHERE f.symbol IN ('BAJAJHLDNG', 'NAUKRI')
ORDER BY f.symbol, f.year_id;


-- Debt-to-Equity Sanity Check --
SELECT

    d.company_name,

    ROUND(f.debt_to_equity, 2) AS debt_to_equity

FROM fact_balance_sheet f

JOIN dim_company d
ON f.symbol = d.symbol

WHERE f.debt_to_equity > 10
   OR f.debt_to_equity < 0

ORDER BY f.debt_to_equity DESC;


-- Validate Free Cash Flow Logic --
SELECT

    symbol,

    operating_activity,
    investing_activity,

    free_cash_flow,

    (operating_activity + investing_activity)
        AS expected_fcf

FROM fact_cash_flow

WHERE free_cash_flow <>
      (operating_activity + investing_activity)

LIMIT 20;