-- Question 2: Transaction Frequency Analysis
-- Scenario: The finance team wants to analyze how often customers transact to segment them (e.g., frequent vs. occasional users).
-- Task: Calculate the average number of transactions per customer per month and categorize them:
-- "High Frequency" (≥10 transactions/month)
SELECT
    CASE
        WHEN subquery.avg_transactions_per_month >= 10 THEN 'High Frequency'
        WHEN subquery.avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS frequency_category,
    COUNT(subquery.id) AS customer_count,
    ROUND(AVG(transaction_count),1) AS avg_transactions_per_month
FROM (
    SELECT
        cu.id,
        cu.name,
        COUNT(sa.id) AS transaction_count,
        TIMESTAMPDIFF(MONTH, MIN(cu.enabled_at), CURDATE()) AS months_active,
        COUNT(sa.id) / NULLIF(TIMESTAMPDIFF(MONTH, MIN(cu.enabled_at), CURDATE()), 0) as avg_transactions_per_month
    FROM clean_users cu
    LEFT JOIN savings_savingsaccount sa ON cu.id = sa.owner_id
    GROUP BY cu.id, cu.name
) AS subquery
WHERE subquery.months_active > 0
GROUP BY frequency_category
ORDER BY
    CASE
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        ELSE 3
    END;