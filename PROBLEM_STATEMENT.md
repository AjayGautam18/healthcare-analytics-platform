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
