-- ============================================================
-- CARD EXPLORATION
-- ============================================================


-- Create card table with parsed issue date
DROP VIEW IF EXISTS dated_card;

CREATE VIEW dated_card AS
SELECT
    card_id,
    disp_id,
    type,
    DATE(
        '19' ||
        SUBSTR(CAST(issued AS TEXT), 1, 2) || '-' ||
        SUBSTR(CAST(issued AS TEXT), 3, 2) || '-' ||
        SUBSTR(CAST(issued AS TEXT), 5, 2)
    ) AS issued_date
FROM card;


-- Total number of cards
SELECT COUNT(DISTINCT card_id)
FROM dated_card;


-- Number of distinct disp_id with a card
SELECT
    COUNT(DISTINCT disp_id)
FROM dated_card
WHERE card_id IS NOT NULL;


-- Check if a disposition can have more than one card
SELECT
    disp_id,
    COUNT(card_id) AS number_of_cards
FROM dated_card
GROUP BY disp_id
HAVING COUNT(card_id) > 1;


-- Number of cards by type
SELECT
    type,
    COUNT(card_id) AS number_of_cards
FROM dated_card
GROUP BY type;


-- Check earliest and latest card issue date
SELECT
    MIN(issued_date) AS earliest_issue_date,
    MAX(issued_date) AS latest_issue_date
FROM dated_card;


-- ============================================================
-- JOIN CARD TO ACCOUNT
-- ============================================================

DROP VIEW IF EXISTS card_with_account;

CREATE VIEW card_with_account AS
SELECT
    c.card_id,
    c.disp_id,
    c.type,
    c.issued_date,
    ab.account_id,
    ab.account_created_at
FROM dated_card AS c
INNER JOIN analytical_base AS ab
    ON c.disp_id = ab.disp_id;


-- Check for cards issued before account creation
SELECT
    card_id,
    issued_date,
    account_id,
    account_created_at
FROM card_with_account
WHERE issued_date < account_created_at;


-- Calculate days between account creation and card issue
SELECT
    card_id,
    issued_date,
    account_id,
    account_created_at,
    CAST(
        julianday(issued_date) - julianday(account_created_at)
        AS INTEGER
    ) AS days_acc_creation_to_card_issue
FROM card_with_account;


-- ============================================================
-- FIRST 60 DAYS
-- Day 0 through Day 59
-- ============================================================


-- Count cards issued within Day 0–59
SELECT
    COUNT(DISTINCT card_id) AS cards_issued_60d
FROM card_with_account
WHERE julianday(issued_date) - julianday(account_created_at) >= 0
  AND julianday(issued_date) - julianday(account_created_at) < 60;


-- Count distinct accounts with at least one card issued within Day 0–59
SELECT
    COUNT(DISTINCT account_id) AS accounts_with_card_60d
FROM card_with_account
WHERE julianday(issued_date) - julianday(account_created_at) >= 0
  AND julianday(issued_date) - julianday(account_created_at) < 60;


-- Check accounts with multiple cards issued within Day 0–59
SELECT
    account_id,
    COUNT(DISTINCT card_id) AS cards_issued_60d
FROM card_with_account
WHERE julianday(issued_date) - julianday(account_created_at) >= 0
  AND julianday(issued_date) - julianday(account_created_at) < 60
GROUP BY account_id
HAVING COUNT(DISTINCT card_id) > 1;


-- Inspect card-type distribution within Day 0–59
SELECT
    type,
    COUNT(DISTINCT card_id) AS number_of_cards
FROM card_with_account
WHERE julianday(issued_date) - julianday(account_created_at) >= 0
  AND julianday(issued_date) - julianday(account_created_at) < 60
GROUP BY type;

-- Number of cards issued bucketized by days after account creation
SELECT
	FLOOR((julianday(issued_date) - julianday(account_created_at))/10) * 10 AS days_bucket,
	COUNT(DISTINCT card_id) AS number_of_cards
FROM card_with_account
GROUP BY FLOOR((julianday(issued_date) - julianday(account_created_at))/10) * 10
ORDER BY days_bucket ASC;