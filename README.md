# Olist E-Commerce Data Analysis

End-to-end data analysis project on the [Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), built with **PostgreSQL** (schema design, SQL-based analysis) and **Python** (pandas, seaborn, scipy) for data cleaning, feature engineering, and statistical analysis.

The project covers customer segmentation (RFM), category-level sales performance, and the relationship between delivery delays and customer satisfaction.

> 📄 For the full narrative write-up with visualizations and business interpretation, see **[REPORT.pdf](./REPORT.pdf)**.
> This README focuses on the technical implementation.

---

## Project Structure

```
├── data/
│   └── raw/                              # Raw Olist CSV files (not tracked, see .gitignore)
├── notebooks/
│   ├── preparation/
│   │   ├── 01_data_preview.ipynb             # Initial look at the raw dataset
│   │   ├── 02_products_to_english.ipynb      # Translating product category names to English
│   │   └── 03_load_data_from_postgresql.ipynb # Pulling data from PostgreSQL, cleaning & merging
│   └── analysis/
│       ├── 01_rfm_analysis.ipynb             # Customer segmentation (RFM)
│       ├── 02_categorical_analysis.ipynb     # Category-level sales & review analysis
│       └── 03_delivery_time_satisfaction_analysis.ipynb  # Delivery delay vs. review score
├── sql/
│   ├── table_preparation/
│   │   ├── 01_create_tables.sql          # Schema definition
│   │   └── 02_foreign_keys.sql           # Foreign key constraints
│   └── analysis/
│       ├── 01_sales_revenue_analysis.sql       # Standalone SQL revenue analysis
│       └── 02_customer_satisfaction_analysis.sql # Standalone SQL satisfaction analysis
├── .env                                  # DB credentials (not tracked, see .gitignore)
├── .gitignore
├── README.md
├── README_TR.md
└── REPORT.pdf                             # Full narrative report with visualizations
```

## Tech Stack

- **Database:** PostgreSQL
- **Python:** pandas, seaborn, scipy, SQLAlchemy (`psycopg2`), python-dotenv
- **Environment:** Jupyter Notebook
- **Version control:** Git / GitHub

## Workflow

The project runs through two stages: **data preparation** (steps 1–6) and **two parallel analysis tracks** — one done directly in SQL, one in Python (steps 7–12).

**1. Data preparation**
1. Download the raw dataset into `data/raw/`
2. `notebooks/preparation/01_data_preview.ipynb` — first look at the raw CSVs (structure, row counts, obvious quality issues)
3. `notebooks/preparation/02_products_to_english.ipynb` — translate `product_category_name` values to English, minor cleanup
4. `sql/table_preparation/01_create_tables.sql` — create the relational schema in PostgreSQL
5. `sql/table_preparation/02_foreign_keys.sql` — add foreign key constraints between tables
6. Import the (cleaned) CSV files into the PostgreSQL tables (manual import, e.g. via pgAdmin's import tool)
7. `notebooks/preparation/03_load_data_from_postgresql.ipynb` — pull raw tables from PostgreSQL via SQLAlchemy, then clean and merge them in pandas (see [Data Quality Notes](#data-quality-notes) below)

**2a. SQL-based analysis (standalone)**
8. `sql/analysis/01_sales_revenue_analysis.sql` — revenue and sales analysis written directly in SQL
9. `sql/analysis/02_customer_satisfaction_analysis.sql` — satisfaction-related analysis written directly in SQL

This track is independent from the Python pipeline below — it demonstrates analysis done purely at the SQL layer (filtering, joins, aggregations).

**2b. Python-based analysis**
10. `notebooks/analysis/01_rfm_analysis.ipynb` — Recency-Frequency-Monetary customer segmentation
11. `notebooks/analysis/02_categorical_analysis.ipynb` — product category performance and review scores
12. `notebooks/analysis/03_delivery_time_satisfaction_analysis.ipynb` — statistical relationship between delivery delay and review score

## Setup & Reproduction

1. Clone the repository and download the [Olist dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) into `data/raw/`
2. Create a `.env` file in the project root with your PostgreSQL credentials:
   ```
   DB_HOST=localhost
   DB_PORT=5432
   DB_NAME=olist
   DB_USER=your_user
   DB_PASSWORD=your_password
   ```
3. Run `sql/table_preparation/01_create_tables.sql` and `02_foreign_keys.sql` against your database
4. Import the raw CSVs into the corresponding tables
5. Install Python dependencies:
   ```
   pip install pandas seaborn scipy sqlalchemy psycopg2-binary python-dotenv jupyter
   ```
6. Run the notebooks in order: `notebooks/preparation/` (`01` → `03`), then `notebooks/analysis/` (`01` → `03`); optionally run the SQL scripts under `sql/analysis/` directly against the database

## Data Quality Notes

A few data quality issues were identified and handled during the process (full detail in the report):

- **775 unmatched `order_items` rows** when checked against order status — traced to specific order statuses rather than random data loss
- **`order_payments` anomaly:** 3 rows tied to a single delivered order with no recorded payment
- **551 duplicate review records** (multiple reviews for the same order) — resolved by keeping the latest `review_answer_timestamp`
- **`order_payments` fan-out bug:** joining `order_payments` directly to `order_items` without deduplication inflated revenue and product counts by roughly 3–5%. Fixed by aggregating `payment_value` per `order_id` before merging.
- **942 null `review_score` values** intentionally retained in the revenue-focused dataframe (dropped only for review-score-specific analyses)

## Limitations

- `order_reviews` has no primary key in the source data
- Only ~3% of customers made a repeat purchase, which limits the depth of frequency-based and cohort/retention analysis
- Market basket / association rule analysis was scoped out — over 99% of orders contain a single product category, making this approach uninformative for this dataset


