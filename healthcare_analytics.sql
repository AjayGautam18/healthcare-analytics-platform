CREATE DATABASE healthcare_db;
   CREATE USER 'healthcare_user'@'localhost' IDENTIFIED BY 'ajay@123';
   GRANT ALL PRIVILEGES ON healthcare_db.* TO 'healthcare_user'@'localhost';
   FLUSH PRIVILEGES;
     SHOW DATABASES;
     use healthcare_db;
     show tables;
     
     select *from encounters;
     
	-- PROBLEM THIS SOLVES:
-- The raw hospital dataset sits as a flat CSV, which makes it hard to answer
-- real operational questions without loading everything into pandas each time.
-- This query library turns that raw data into a queryable analytics layer,
-- answering the kinds of questions a hospital administrator, finance team, or
-- care coordinator would actually ask:

-- ============================================================
-- Healthcare Analytics: SQL Query Library
-- ============================================================
--
-- PROBLEM THIS SOLVES:
-- The raw hospital dataset sits as a flat CSV, which makes it hard to answer
-- real operational questions without loading everything into pandas each time.
-- This query library turns that raw data into a queryable analytics layer,
-- answering the kinds of questions a hospital administrator, finance team, or
-- care coordinator would actually ask:
--
--   - Which conditions and hospitals drive the highest billing?
--   - How does patient volume trend over time (monthly, yearly)?
--   - How does length of stay compare across conditions and admission types?
--   - Which doctors/hospitals handle the most patients?
--   - Are there outlier cases with unusually high billing for their condition?
--
-- Each query is written as standalone, runnable SQL - covering aggregations,
-- CTEs, window functions (RANK, LAG, PERCENT_RANK, running totals), and
-- subqueries - rather than relying on pandas groupby alone. This demonstrates
-- the kind of analytical SQL used in real BI/data analyst workflows, on top
-- of a database (SQLite or MySQL) built from the same cleaned data used in
-- the notebook analysis.
--
-- Run against sql/healthcare.db (SQLite) or the MySQL 'encounters' table
-- built via sql/build_db.py / sql/build_db_mysql.py.
-- ============================================================


-- 1. Average billing and patient volume by medical condition, ranked
SELECT
    medical_condition,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(length_of_stay), 1) AS avg_length_of_stay
FROM encounters
GROUP BY medical_condition
ORDER BY avg_billing DESC;


-- 2. Top 5 hospitals by average billing amount (min 50 patients, to avoid noise from tiny samples)
SELECT
    hospital,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM encounters
GROUP BY hospital
HAVING COUNT(*) >= 50
ORDER BY avg_billing DESC
LIMIT 5;


-- 3. Month-over-month admission trend (all years combined)
SELECT
    admission_month,
    COUNT(*) AS admissions
FROM encounters
GROUP BY admission_month
ORDER BY
    CASE admission_month
        WHEN 'January' THEN 1 WHEN 'February' THEN 2 WHEN 'March' THEN 3
        WHEN 'April' THEN 4 WHEN 'May' THEN 5 WHEN 'June' THEN 6
        WHEN 'July' THEN 7 WHEN 'August' THEN 8 WHEN 'September' THEN 9
        WHEN 'October' THEN 10 WHEN 'November' THEN 11 WHEN 'December' THEN 12
    END;


-- 4. Length-of-stay percentile ranking by condition (window function)
-- Shows where each condition's average LOS ranks against all others
SELECT
    medical_condition,
    ROUND(AVG(length_of_stay), 2) AS avg_los,
    RANK() OVER (ORDER BY AVG(length_of_stay) DESC) AS los_rank,
    ROUND(PERCENT_RANK() OVER (ORDER BY AVG(length_of_stay)), 3) AS percentile
FROM encounters
GROUP BY medical_condition;


-- 5. Running total of billing amount by year (window function, cumulative)
SELECT
    admission_year,
    COUNT(*) AS admissions,
    ROUND(SUM(billing_amount), 2) AS yearly_billing,
    ROUND(SUM(SUM(billing_amount)) OVER (ORDER BY admission_year), 2) AS cumulative_billing
FROM encounters
GROUP BY admission_year
ORDER BY admission_year;


-- 6. Insurance provider comparison: volume, avg billing, avg length of stay
SELECT
    insurance_provider,
    COUNT(*) AS patient_count,
    ROUND(AVG(billing_amount), 2) AS avg_billing,
    ROUND(AVG(length_of_stay), 1) AS avg_length_of_stay,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM encounters), 2) AS pct_of_total
FROM encounters
GROUP BY insurance_provider
ORDER BY avg_billing DESC;


-- 7. Admission type breakdown with billing (CTE example)
WITH admission_stats AS (
    SELECT
        admission_type,
        COUNT(*) AS total,
        AVG(billing_amount) AS avg_bill,
        AVG(length_of_stay) AS avg_los
    FROM encounters
    GROUP BY admission_type
)
SELECT
    admission_type,
    total,
    ROUND(avg_bill, 2) AS avg_billing,
    ROUND(avg_los, 1) AS avg_length_of_stay,
    ROUND(100.0 * total / (SELECT SUM(total) FROM admission_stats), 2) AS pct_of_admissions
FROM admission_stats
ORDER BY total DESC;


-- 8. Doctors handling the highest patient volume (top 10)
SELECT
    doctor,
    COUNT(*) AS patients_treated,
    ROUND(AVG(billing_amount), 2) AS avg_billing
FROM encounters
GROUP BY doctor
ORDER BY patients_treated DESC
LIMIT 10;


-- 9. Test result outcomes by admission type (cross-tab style)
SELECT
    admission_type,
    SUM(CASE WHEN test_results = 'Normal' THEN 1 ELSE 0 END) AS normal_count,
    SUM(CASE WHEN test_results = 'Abnormal' THEN 1 ELSE 0 END) AS abnormal_count,
    SUM(CASE WHEN test_results = 'Inconclusive' THEN 1 ELSE 0 END) AS inconclusive_count,
    COUNT(*) AS total
FROM encounters
GROUP BY admission_type;


-- 10. Age band vs. condition matrix (which age bands see which conditions most)
SELECT
    age_band,
    medical_condition,
    COUNT(*) AS patient_count
FROM encounters
GROUP BY age_band, medical_condition
ORDER BY age_band, patient_count DESC;


-- 11. Patients with above-average billing for their condition (subquery)
-- Useful for flagging high-cost outlier cases per diagnosis group
SELECT
    e.name,
    e.medical_condition,
    e.billing_amount,
    cond_avg.avg_billing AS condition_avg_billing,
    ROUND(e.billing_amount - cond_avg.avg_billing, 2) AS amount_above_avg
FROM encounters e
JOIN (
    SELECT medical_condition, AVG(billing_amount) AS avg_billing
    FROM encounters
    GROUP BY medical_condition
) cond_avg ON e.medical_condition = cond_avg.medical_condition
WHERE e.billing_amount > cond_avg.avg_billing * 1.5
ORDER BY amount_above_avg DESC
LIMIT 20;


-- 12. Length of stay bucket distribution by admission type
SELECT
    admission_type,
    los_bucket,
    COUNT(*) AS patient_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY admission_type), 2) AS pct_within_type
FROM encounters
GROUP BY admission_type, los_bucket
ORDER BY admission_type, los_bucket;


-- 13. Year-over-year growth rate in admissions (window function: LAG)
SELECT
    admission_year,
    COUNT(*) AS admissions,
    LAG(COUNT(*)) OVER (ORDER BY admission_year) AS prev_year_admissions,
    ROUND(
        100.0 * (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY admission_year))
        / LAG(COUNT(*)) OVER (ORDER BY admission_year), 2
    ) AS pct_change
FROM encounters
GROUP BY admission_year
ORDER BY admission_year;


-- 14. Blood type distribution across conditions (are certain blood types over-represented?)
SELECT
    blood_type,
    medical_condition,
    COUNT(*) AS patient_count
FROM encounters
GROUP BY blood_type, medical_condition
ORDER BY blood_type, patient_count DESC;


-- 15. Weekday admission volume with rank
SELECT
    admission_weekday,
    COUNT(*) AS admissions,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS volume_rank
FROM encounters
GROUP BY admission_weekday;
     