-- Validate → fact_profit_loss --
SELECT DISTINCT f.symbol

FROM fact_profit_loss f

LEFT JOIN dim_company d
ON f.symbol = d.symbol

WHERE d.symbol IS NULL;


-- Validate → fact_balance_sheet --
SELECT DISTINCT f.symbol

FROM fact_balance_sheet f

LEFT JOIN dim_company d
ON f.symbol = d.symbol

WHERE d.symbol IS NULL;


-- Validate → fact_cash_flow --
SELECT DISTINCT f.symbol

FROM fact_cash_flow f

LEFT JOIN dim_company d
ON f.symbol = d.symbol

WHERE d.symbol IS NULL;


-- Validate → fact_analysis --
SELECT DISTINCT f.symbol

FROM fact_analysis f

LEFT JOIN dim_company d
ON f.symbol = d.symbol

WHERE d.symbol IS NULL;


-- Validate → fact_pros_cons --
SELECT DISTINCT f.symbol

FROM fact_pros_cons f

LEFT JOIN dim_company d
ON f.symbol = d.symbol

WHERE d.symbol IS NULL;