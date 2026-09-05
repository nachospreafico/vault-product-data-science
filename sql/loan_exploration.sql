-- ============================================================
-- Loan exploration
-- Assess whether loan behaviour is observable within the
-- first 60 days after account creation.
-- ============================================================


-- ------------------------------------------------------------
-- 1. Parse loan grant date
-- ------------------------------------------------------------

DROP VIEW IF EXISTS dated_loan;

CREATE VIEW dated_loan AS
SELECT
    loan_id,
    account_id,
    DATE(
        '19' ||
        SUBSTR(CAST(date AS TEXT), 1, 2) || '-' ||
        SUBSTR(CAST(date AS TEXT), 3, 2) || '-' ||
        SUBSTR(CAST(date AS TEXT), 5, 2)
    ) AS grant_date,
    amount,
    duration,
    payments,
    status
FROM loan;


-- ------------------------------------------------------------
-- 2. Basic loan profiling
-- ------------------------------------------------------------

-- Total number of loans
SELECT
    COUNT(DISTINCT loan_id) AS total_loans
FROM dated_loan;


-- Number of loans per account
SELECT
    account_id,
    COUNT(DISTINCT loan_id) AS total_loans
FROM dated_loan
GROUP BY account_id
ORDER BY total_loans DESC;


-- Check whether an account can have multiple loans
SELECT
    account_id,
    COUNT(DISTINCT loan_id) AS total_loans
FROM dated_loan
GROUP BY account_id
HAVING COUNT(DISTINCT loan_id) > 1
ORDER BY total_loans DESC;


-- Earliest and latest loan grant dates
SELECT
    MIN(grant_date) AS earliest_loan_date,
    MAX(grant_date) AS latest_loan_date
FROM dated_loan;


-- ------------------------------------------------------------
-- 3. Attach account lifecycle information
-- ------------------------------------------------------------

DROP VIEW IF EXISTS loan_with_account;

CREATE VIEW loan_with_account AS

WITH deduplicated_accounts AS (
    SELECT DISTINCT
        account_id,
        account_created_at
    FROM analytical_base
)

SELECT
    dl.loan_id,
    dl.grant_date,
    da.account_id,
    da.account_created_at
FROM dated_loan AS dl
INNER JOIN deduplicated_accounts AS da
    ON dl.account_id = da.account_id;


-- ------------------------------------------------------------
-- 4. Validate loan timing
-- ------------------------------------------------------------

-- Check for loans granted before account creation
SELECT
    loan_id,
    account_id,
    account_created_at,
    grant_date
FROM loan_with_account
WHERE grant_date < account_created_at;


-- Calculate days from account creation to loan grant
SELECT
    loan_id,
    account_id,
    account_created_at,
    grant_date,
    CAST(
        julianday(grant_date) - julianday(account_created_at)
        AS INTEGER
    ) AS days_to_loan
FROM loan_with_account
ORDER BY days_to_loan ASC;


-- Distribution of days to loan in 10-day buckets
SELECT
    FLOOR(
        (julianday(grant_date) - julianday(account_created_at)) / 10
    ) * 10 AS days_bucket,
    COUNT(*) AS number_of_loans
FROM loan_with_account
GROUP BY days_bucket
ORDER BY days_bucket ASC;


-- ------------------------------------------------------------
-- 5. Assess eligibility for the 60-day observation window
-- ------------------------------------------------------------

-- Loans granted during Day 0-59
SELECT
    COUNT(*) AS loans_within_60d
FROM loan_with_account
WHERE julianday(grant_date) - julianday(account_created_at) >= 0
  AND julianday(grant_date) - julianday(account_created_at) < 60;


-- Accounts taking a loan during Day 0-59
SELECT
    COUNT(DISTINCT account_id) AS accounts_with_loan_60d
FROM loan_with_account
WHERE julianday(grant_date) - julianday(account_created_at) >= 0
  AND julianday(grant_date) - julianday(account_created_at) < 60;