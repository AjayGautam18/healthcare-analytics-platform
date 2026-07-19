# healthcare-analytics-platform

An end-to-end analytics project on hospital patient records — combining exploratory data
analysis, SQL-based operational querying, and (optionally) an interactive dashboard.

See [`PROBLEM_STATEMENT.md`](PROBLEM_STATEMENT.md) for the full problem framing and scope.

## About

This started as a basic EDA notebook on a Kaggle healthcare dataset. It's since been expanded
into a multi-layer analytics project:

1. **Extended EDA & Visualization** — demographic, clinical, financial, and temporal patterns
   explored through a broader set of charts than a typical starter notebook
2. **SQL analytics layer** — the data modeled into a relational database, queried with real
   analytical SQL (window functions, CTEs, multi-way aggregations) to answer operational
   business questions

## Dataset

**Source:** [Kaggle - Healthcare Dataset](https://www.kaggle.com/datasets/prasad22/healthcare-dataset)

55,500 patient encounters (2019–2024) across 15 fields: demographics (age, gender, blood type),
clinical (condition, medication, test results), administrative (doctor, hospital, room,
admission/discharge dates, admission type), and financial (billing amount, insurance provider).

**Important caveat:** this dataset is synthetic and randomly generated — distributions are
near-uniform across nearly every categorical and numeric field, with little to no
inter-variable correlation. This project treats that as a known constraint: no predictive
modeling is attempted (it would fit noise, not signal), and the value of the work is in the
analytics engineering itself — the SQL layer and the visual analysis — which would transfer
directly to a real dataset.

## Project Structure

```
├── PROBLEM_STATEMENT.md          # problem framing, scope, deliverables
├── dataset/                      # raw data
├── healthcare_analytics.sql      # SQL query library (analytical queries)
├── healthcare_analytics.ipynb    # main notebook (data cleaning + EDA + visualization)
├── requirements.txt
└── README.md
```

## Methodology

### 1. Data Cleaning & Feature Engineering
- Standardized column names, fixed text formatting, parsed dates
- Engineered `length_of_stay`, age bands, and admission year/month/weekday

### 2. SQL Analytics Layer
- Realistic operational questions answered with SQL: cost drivers by condition/insurance,
  length-of-stay patterns by admission type, provider/hospital-level aggregates, temporal
  admission trends, window-function-based rankings

## Setup

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# notebook
jupyter notebook
```

## Tools Used

- **pandas / numpy** — data manipulation
- **matplotlib / seaborn** — visualization
- **sqlite3 / SQLAlchemy** — relational data modeling and SQL querying


## Future Work

- Interactive dashboard for filtering and exploring results without writing code
- Swap in a real hospital dataset (e.g. Diabetes 130-US hospitals readmissions) to enable
  genuine predictive modeling on top of the same SQL and analysis foundation
