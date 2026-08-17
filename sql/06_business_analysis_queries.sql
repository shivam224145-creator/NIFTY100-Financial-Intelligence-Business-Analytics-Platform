--1.1 BASIC JOIN
SELECT 
    c.symbol,
    c.company_name,
    a.period,
    a.sales_growth,
    a.profit_growth,
    a.stock_cagr,
    a.roe
FROM companies c
JOIN analysis a 
ON c.symbol = a.symbol
LIMIT 20;

--1.2 Only 10Y performing companies
SELECT 
    c.company_name,
    a.sales_growth,
    a.profit_growth,
    a.stock_cagr,
    a.roe
FROM companies c
JOIN analysis a 
ON c.symbol = a.symbol
WHERE a.period = '10Y'
ORDER BY a.sales_growth DESC;

--1.3 Top 10 companies by ROE (10Y)
SELECT 
    c.company_name,
    a.roe
FROM companies c
JOIN analysis a 
ON c.symbol = a.symbol
WHERE a.period = '10Y'
ORDER BY a.roe DESC
LIMIT 10;

--1.4 joins cross check
SELECT COUNT(*) 
FROM analysis a
JOIN companies c ON a.symbol = c.symbol;

--1.5 Multi-table join test
SELECT 
    c.company_name,
    a.sales_growth,
    p.sales,
    b.debt_to_equity
FROM companies c
JOIN analysis a ON c.symbol = a.symbol
JOIN profitloss p ON c.symbol = p.symbol
JOIN balancesheet b ON c.symbol = b.symbol
LIMIT 10;

--1.6 Company count
SELECT COUNT(DISTINCT symbol) 
FROM companies;

--1.7 Available years in dataset
SELECT DISTINCT fiscal_year 
FROM profitloss
ORDER BY fiscal_year;

--2.1 Profitability check
SELECT 
    p.symbol,
    p.fiscal_year,
    p.sales,
    p.net_profit,
    (p.net_profit * 100.0 / p.sales) AS profit_margin
FROM profitloss p
WHERE p.sales > 0
ORDER BY profit_margin DESC
LIMIT 10;

--2.2 Revenue Growth Trend
SELECT 
    symbol,
    fiscal_year,
    sales,
    LAG(sales) OVER (PARTITION BY symbol ORDER BY fiscal_year) AS prev_sales
FROM profitloss;

--2.3 Year-on-Year Growth %
SELECT 
    symbol,
    fiscal_year,
    sales,
    ROUND((sales - LAG(sales) OVER (PARTITION BY symbol ORDER BY fiscal_year)) 
          *100.0 / NULLIF(LAG(sales) OVER (PARTITION BY symbol ORDER BY fiscal_year),0),2) 
          AS yoy_growth
FROM profitloss;

--2.4 Top companies by Net Profit (latest year)
SELECT 
    symbol,
    net_profit
FROM profitloss
WHERE fiscal_year = (SELECT MAX(fiscal_year) FROM profitloss)
ORDER BY net_profit DESC
LIMIT 10;

--2.5 Avg ROCE vs ROE comparison
SELECT 
    symbol,
    AVG(roce) AS avg_roce,
    AVG(roe) AS avg_roe
FROM companies
GROUP BY symbol
ORDER BY avg_roce DESC;

--3.1 Growth vs Debt (High growth but risky)
SELECT 
    c.company_name,
    a.sales_growth,
    b.debt_to_equity
FROM analysis a
JOIN balancesheet b ON a.symbol = b.symbol
JOIN companies c ON c.symbol = a.symbol
WHERE a.period = '10Y'
ORDER BY a.sales_growth DESC, b.debt_to_equity DESC;

--3.2 Profit vs Cash Flow mismatch (Danger signal)
SELECT 
    symbol,
    AVG(net_profit) AS avg_profit,
    AVG(free_cash_flow) AS avg_fcf
FROM profitloss p
JOIN cashflow c USING(symbol)
GROUP BY symbol
HAVING AVG(net_profit) > 0 AND AVG(free_cash_flow) < 0;

--3.3 Consistent Growers (multi-year stability)
SELECT 
    symbol,
    COUNT(*) AS years_present
FROM profitloss
GROUP BY symbol
HAVING COUNT(*) > 8
ORDER BY years_present DESC;

--3.4 High ROE + Low Debt (Best companies)
SELECT 
    c.company_name,
    AVG(a.roe) AS avg_roe,
    AVG(b.debt_to_equity) AS avg_debt
FROM analysis a
JOIN balancesheet b ON a.symbol = b.symbol
JOIN companies c ON c.symbol = a.symbol
GROUP BY c.company_name
ORDER BY avg_roe DESC, avg_debt ASC
LIMIT 10;

--3.5 Efficiency + Profit combo (Elite companies)
SELECT 
    p.symbol,
    AVG(p.net_profit_margin) AS profit_margin,
    AVG(p.expense_ratio) AS expense_ratio
FROM profitloss p
GROUP BY p.symbol
ORDER BY profit_margin DESC, expense_ratio ASC
LIMIT 10;

--4.1 Top Consistent Profit Companies (Avg Profit Margin)
SELECT 
    p.symbol,
    AVG(p.net_profit * 100.0 / NULLIF(p.sales,0)) AS avg_profit_margin
FROM profitloss p
GROUP BY p.symbol
ORDER BY avg_profit_margin DESC
LIMIT 10;

--4.2 Best ROE Companies (Long-term performance)
SELECT 
    c.company_name,
    MAX(a.roe) AS best_roe
FROM analysis a
JOIN companies c ON a.symbol = c.symbol
GROUP BY c.company_name
ORDER BY best_roe DESC
LIMIT 10;

--4.3 Debt Risk Analysis (High Debt Companies)
SELECT 
    symbol,
    AVG(debt_to_equity) AS avg_debt
FROM balancesheet
GROUP BY symbol
ORDER BY avg_debt DESC
LIMIT 10;

--4.4 Cash Flow Strength (Healthy Companies)
SELECT 
    symbol,
    AVG(free_cash_flow) AS avg_fcf
FROM cashflow
GROUP BY symbol
ORDER BY avg_fcf DESC
LIMIT 10;

--4.5 Growth vs Profit Comparison
SELECT 
    c.company_name,
    a.sales_growth,
    a.profit_growth
FROM analysis a
JOIN companies c ON a.symbol = c.symbol
WHERE a.period = '10Y'
ORDER BY a.sales_growth DESC;

--4.6 Most Efficient Companies (Low Expense Ratio)
SELECT 
    symbol,
    AVG(expense_ratio) AS avg_expense
FROM profitloss
GROUP BY symbol
ORDER BY avg_expense ASC
LIMIT 10;

--4.7 Interest Coverage (Safe Companies)
SELECT 
    symbol,
    AVG(interest_coverage) AS avg_ic
FROM profitloss
GROUP BY symbol
ORDER BY avg_ic DESC
LIMIT 10;