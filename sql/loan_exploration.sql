-- Create a parsed date view of loan.csv
CREATE VIEW dated_loan AS
	SELECT
		loan_id,
		account_id,
		DATE(
			'19' || SUBSTR(date, 1, 2) || '-' || SUBSTR(date, 3, 2) || '-' || SUBSTR(date, 5, 2)
		) AS grant_date,
		amount,
		duration,
		payments,
		status
	FROM loan

SELECT *
FROM dated_loan

-- Total loans
SELECT
	COUNT(DISTINCT loan_id) AS total_loan
FROM dated_loan

-- Distinct accounts with loans
SELECT
	account_id,
	COUNT(DISTINCT loan_id) AS total_loans
FROM dated_loan
GROUP BY account_id;

-- Check whether an account can have multiple loans
SELECT
	account_id,
	COUNT(DISTINCT loan_id) AS total_loans
FROM dated_loan
GROUP BY account_id
HAVING COUNT(DISTINCT loan_id) > 1;

-- Check earliest/latest loan dates
SELECT
	MIN(grant_date) AS earliest_date,
	MAX(grant_date) AS latest_date
FROM dated_loan;

--
WITH DeduplicatedAccountId AS (
	SELECT DISTINCT account_id, account_created_at
	FROM analytical_base
)
SELECT
	loan_id,
	grant_date,
	account_id,
	account_created_at
FROM dated_loan dl
JOIN analytical_base ab
ON dl.account_id = ab.account_id