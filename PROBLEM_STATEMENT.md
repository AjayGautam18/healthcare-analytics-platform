# Problem Statement

## Context

Hospitals and insurers generate large volumes of patient-level operational data — admissions,
billing, diagnoses, insurance, length of stay — but this data is often locked inside
transactional systems and never turned into something decision-makers can actually query
or look at. Before any organization can justify investing in predictive modeling, it needs
a reliable **descriptive and diagnostic analytics layer**: clean data, a queryable structure,
validated patterns, and visuals that non-technical stakeholders (hospital admins, finance
teams, care coordinators) can actually use.

## Problem

Given a raw hospital records dataset (55,500 patient encounters, 15 attributes spanning
demographics, clinical, financial, and administrative fields), there is no structured way to:

1. Query the data flexibly to answer operational questions (e.g. *"which insurance provider
   has the highest average billing for emergency admissions?"*, *"how does length of stay vary
   by doctor/hospital/condition?"*)
2. Visually communicate patterns across demographic, financial, and administrative dimensions
   in a way that holds up to statistical scrutiny rather than eyeballed charts
3. Let a stakeholder explore the data interactively (filter by condition, date range, insurance,
   admission type) without writing code

## Objective

Build an end-to-end **healthcare analytics platform** that:

- Cleans and models the raw CSV into a proper relational structure (SQLite)
- Answers real operational questions using SQL (aggregations, window functions, CTEs — not
  just `pandas.groupby`)
- Produces a comprehensive, statistically-grounded set of visualizations covering demographics,
  clinical patterns, financial patterns, and temporal/operational trends
- Ships as an interactive dashboard so a non-technical user can explore the data themselves,
  filter dynamically, and see KPIs update live

## Explicit Non-Goal: Predictive Modeling

This dataset (Kaggle `prasad22/healthcare-dataset`) is synthetic and randomly generated —
age, condition, billing, and insurance are all near-uniformly distributed with no meaningful
correlation structure between them (verified in Phase 1 EDA). Training a predictive model on
it would optimize against noise and produce metrics that look real but mean nothing. This
project intentionally scopes to **descriptive + diagnostic analytics**, where the value of
the work stands independent of the data's synthetic nature. Predictive modeling is documented
as future work, contingent on swapping in a dataset with genuine signal (e.g. a real hospital
readmissions dataset).

## Deliverables

| Deliverable | Purpose |
|---|---|
| `analysis.ipynb` | Extended EDA: full visual suite + statistical validation |
| `sql/` | SQLite database + a library of analytical SQL queries answering operational questions |
| `dashboard/` | Interactive Streamlit dashboard with filters and live KPIs |
| `results/` | Saved static plots and findings for the README/report |

## Success Criteria

- Every visual claim in the analysis is backed by a statistical test, not eyeballing
- SQL query library answers a defined set of realistic operational/business questions
- Dashboard runs locally with one command and lets a user filter without touching code
- Project is reproducible end-to-end from raw CSV to dashboard
