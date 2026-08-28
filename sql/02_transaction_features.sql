CREATE VIEW transaction_features AS

WITH deduplicated_accounts AS (
    SELECT DISTINCT
        account_id,
        account_created_at
    FROM analytical_base
),

transactions_dated AS (
    SELECT
        da.account_id,
        da.account_created_at,
        tx.trans_id,
        tx.type,
        tx.operation,
        tx.amount,
        DATE(
            '19' ||
            SUBSTR(CAST(tx.date AS TEXT), 1, 2) || '-' ||
            SUBSTR(CAST(tx.date AS TEXT), 3, 2) || '-' ||
            SUBSTR(CAST(tx.date AS TEXT), 5, 2)
        ) AS transaction_date

    FROM deduplicated_accounts AS da
    INNER JOIN trans AS tx
        ON da.account_id = tx.account_id
),

transactions_60d AS (
    SELECT *
    FROM transactions_dated
    WHERE transaction_date >= account_created_at
      AND transaction_date < DATE(account_created_at, '+60 days')
)

SELECT
    account_id,
    COUNT(trans_id) AS transaction_count_60d,

    SUM(
        CASE
            WHEN type = 'PRIJEM' THEN amount
            ELSE 0
        END
    ) AS total_inflow_60d,

    SUM(
        CASE
            WHEN type IN ('VYDAJ', 'VYBER') THEN amount
            ELSE 0
        END
    ) AS total_outflow_60d,

    AVG(amount) AS avg_transaction_amount_60d,

    COUNT(DISTINCT transaction_date) AS active_days_60d

FROM transactions_60d
GROUP BY account_id;