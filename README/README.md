\# 📊 NIFTY100 Financial Intelligence \& Business Analytics Platform



\## ⭐ Production-Grade Data Engineering, Financial Analytics \& Business Intelligence Project



A complete end-to-end Financial Intelligence Platform built for NIFTY100 companies using Python, PostgreSQL, SQL, Machine Learning-inspired Financial Scoring, and Power BI.



The project transforms raw financial datasets into actionable business intelligence through ETL pipelines, dimensional data warehousing, advanced financial metrics, ML-based company health scoring, and interactive executive dashboards.



\---



\# 🚀 Project Objective



Build a production-style financial analytics system capable of:



\- Extracting and transforming raw financial data

\- Designing a PostgreSQL star-schema warehouse

\- Generating ML-inspired financial health scores

\- Performing company and sector-level analytics

\- Creating executive Power BI dashboards

\- Supporting future API and application integrations



\---



\# 🏗️ Project Architecture



```text

Raw Excel Files / SQL Export

&#x20;       ↓

Python Extraction Layer

&#x20;       ↓

Python Cleaning \& Transformation Layer

&#x20;       ↓

Sector Enrichment \& ML Scoring

&#x20;       ↓

Clean Analytical CSV Files

&#x20;       ↓

PostgreSQL Star Schema Warehouse

&#x20;       ↓

Dimension \& Fact Tables

&#x20;       ↓

Advanced Financial Intelligence Metrics

&#x20;       ↓

Machine Learning Health Score Engine

&#x20;       ↓

Power BI Executive Dashboards

&#x20;       ↓

Business Intelligence \& Comparative Analytics

```



\---



\# 📂 Dataset Overview



The project uses multi-year financial data of NIFTY100 companies.



\### Main Source Files



\- companies.xlsx

\- balancesheet.xlsx

\- cashflow.xlsx

\- analysis.xlsx

\- profitandloss.xlsx

\- prosandcons.xlsx



\### Data Includes



\- Company Information

\- Revenue \& Profit Metrics

\- Balance Sheet Data

\- Cashflow Data

\- Growth Indicators

\- Profitability Ratios

\- Debt Information

\- Sector Classification

\- Business Pros \& Cons



\---



\# ⚙️ Technology Stack



\## Programming \& Analytics



\- Python

\- Pandas

\- NumPy

\- Matplotlib

\- Seaborn

\- Regex



\## Database



\- PostgreSQL

\- pgAdmin 4

\- SQL



\## Data Engineering



\- ETL Pipelines

\- Data Cleaning

\- Data Transformation

\- Data Validation



\## Business Intelligence



\- Power BI Desktop

\- Power Query

\- DAX



\## Development Environment



\- Jupyter Notebook

\- Notepad

\- GitHub



\---



\# 🔄 ETL Pipeline



The project uses a modular ETL architecture.



\## 01\_extract\_from\_mysql.py



Responsible for:



\- Source extraction

\- File validation

\- Dataset ingestion

\- Structured data loading



\## 02\_clean\_transform.py



Responsible for:



\- Data cleaning

\- Missing value handling

\- Data type correction

\- Fiscal year extraction

\- Metric engineering

\- Sector enrichment

\- ML scoring preparation



\## 03\_load\_to\_postgres.py



Responsible for:



\- Warehouse loading

\- Fact table loading

\- Dimension table loading

\- Validation checks

\- Warehouse synchronization



\---



\# 🏛️ PostgreSQL Star Schema Warehouse



\## Dimension Tables



\### dim\_company



Stores:



\- Company details

\- Website links

\- NSE/BSE references

\- Sector information

\- Company metadata



\### dim\_year



Stores:



\- Fiscal year

\- Reporting period

\- Sort order

\- Time intelligence attributes



\### dim\_sector



Stores:



\- Sector classification

\- Sector codes

\- Business categories



\### dim\_health\_label



Stores:



\- EXCELLENT

\- GOOD

\- AVERAGE

\- WEAK

\- POOR



Health scoring references.



\---



\## Fact Tables



\### fact\_analysis



Growth metrics and ROE analysis.



\### fact\_balance\_sheet



Balance sheet intelligence.



\### fact\_cash\_flow



Cashflow analytics.



\### fact\_profit\_loss



Profitability analysis.



\### fact\_pros\_cons



Business insight repository.



\### fact\_ml\_scores



ML-generated financial scoring engine.



\---



\# 🧮 Advanced Financial Metrics



The following metrics were engineered and calculated:



\- Debt-to-Equity Ratio

\- Net Profit Margin %

\- Expense Ratio %

\- Interest Coverage Ratio

\- Free Cash Flow

\- Cash Conversion Ratio

\- Asset Turnover

\- Return on Assets (ROA)

\- Equity Ratio



\---



\# 🤖 ML Health Scoring System



A custom financial health scoring framework was developed.



\## Scoring Components



\- Profitability Score

\- Growth Score

\- Leverage Score

\- Cashflow Score

\- Dividend Score

\- Trend Score



\## Health Categories



\### Dashboard Classification



\- STRONG

\- MODERATE

\- WEAK



\### Warehouse Classification



\- EXCELLENT

\- GOOD

\- AVERAGE

\- WEAK

\- POOR



\---



\# 🧠 Sector Intelligence Layer



A dedicated sector enrichment pipeline was implemented.



\### Major Sectors



\- IT

\- Banking

\- NBFC

\- Insurance

\- Energy

\- Power

\- FMCG

\- Pharma

\- Auto

\- Cement

\- Healthcare

\- Consumer Goods

\- Ports

\- Telecom



\### Deliverables



\- sector\_mapping.csv

\- updated\_companies\_clean.csv

\- company\_sector\_intelligence.csv



\---



\# 📈 Power BI Dashboards



\## Dashboard 1 — Executive Overview



Provides:



\- Overall Financial Health

\- Company Distribution

\- Executive KPIs

\- Top Companies



\---



\## Dashboard 2 — Profitability \& Growth Analysis



Provides:



\- Profit Margin Analysis

\- Expense Analysis

\- Growth Comparisons



\---



\## Dashboard 3 — Debt \& Cashflow Risk Analysis



Provides:



\- Debt Evaluation

\- Cashflow Intelligence

\- Financial Risk Analysis



\---



\## Dashboard 4 — ML Health Scoring Analysis



Provides:



\- Health Category Analysis

\- ML Score Distribution

\- Company Ranking



\---



\## Dashboard 5 — Advanced Financial Score Analysis



Provides:



\- Score Decomposition

\- Growth Score Analysis

\- Dividend Score Analysis

\- Leverage Evaluation



\---



\## Dashboard 6 — Company Deep Dive Dashboard



Provides:



\- Dynamic Company Analysis

\- DAX KPI Cards

\- Company Intelligence

\- Detailed Financial Review



\---



\## Dashboard 7 — Sector \& Comparative Intelligence



Provides:



\- Sector Performance Comparison

\- Strong vs Weak Companies

\- Industry Benchmarking

\- Comparative Analytics



\---



\# 🔍 Key Business Insights



\### 1. Financial Strength Distribution



Strong companies consistently demonstrate:



\- Higher profitability

\- Better leverage control

\- Stronger cashflow generation



\---



\### 2. Sector-Level Intelligence



IT, FMCG, and selected Power sector companies show stronger financial stability and operational efficiency.



\---



\### 3. Risk Identification



Debt-heavy companies generally show weaker financial scores and reduced cashflow flexibility.



\---



\### 4. Growth \& Dividend Impact



Companies with consistent growth and dividend performance achieve significantly higher overall health scores.



\---



\### 5. Sector Benchmarking



Sector intelligence enables direct comparison of companies operating within the same industry.



\---



\### 6. ML Scoring Advantage



The scoring framework simplifies complex financial analysis into business-friendly performance indicators.



\---



\### 7. Executive Decision Support



The dashboards help identify:



\- High-performing companies

\- Financially risky companies

\- Growth opportunities

\- Sector leaders



\---



\# 📊 Project Outcomes



✅ End-to-End ETL Automation



✅ PostgreSQL Data Warehouse



✅ Star Schema Modelling



✅ Advanced Financial Analytics



✅ ML-Inspired Health Scoring



✅ Sector Intelligence Framework



✅ 7 Interactive Power BI Dashboards



✅ DAX-Based KPI Reporting



✅ Executive-Level Business Intelligence



✅ Production-Style Analytics Workflow



\---



\# ⚠ Important Notes



\- Always use \*\_clean.csv files for analytics.

\- Do not use raw files directly in dashboards.

\- Execute ETL scripts in sequence:

&#x20; - 01\_extract\_from\_mysql.py

&#x20; - 02\_clean\_transform.py

&#x20; - 03\_load\_to\_postgres.py

\- Maintain synchronization between PostgreSQL warehouse and Power BI datasets.

\- Database credentials should be handled through environment variables.

\- `book\_value\_per\_share` was not implemented because `shares\_outstanding` data was unavailable in the source datasets.



\---



\# 👨‍💻 Author



\*\*Shivam Shukla\*\*



Data Analytics | Data Engineering | Business Intelligence



\---



⭐ If you found this project useful, consider giving it a star.

