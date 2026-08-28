CREATE VIEW analytical_base AS

SELECT
    c.client_id,
    a.account_id,
    d.disp_id,
    d.type AS disp_type,
    DATE(
        '19' ||
        SUBSTR(CAST(a.date AS TEXT), 1, 2) || '-' ||
        SUBSTR(CAST(a.date AS TEXT), 3, 2) || '-' ||
        SUBSTR(CAST(a.date AS TEXT), 5, 2)
    ) AS account_created_at

FROM client AS c
INNER JOIN disp AS d
    ON c.client_id = d.client_id
INNER JOIN account AS a
    ON d.account_id = a.account_id;