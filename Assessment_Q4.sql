-- Question 4: Customer Lifetime Value (CLV) Estimation
-- Scenario: Marketing wants to estimate CLV based on account tenure and transaction volume (simplified model).
-- Task: For each customer, assuming the profit_per_transaction is 0.1% of the transaction value, calculate:
-- Account tenure (months since signup)
-- Total transactions
-- Estimated CLV (Assume: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction)
-- Order by estimated CLV from highest to lowest
SELECT
    cu.id AS customer_id,
    cu.name,
    TIMESTAMPDIFF(MONTH, cu.enabled_at, CURDATE()) AS tenure_months,
    COUNT(sa.id) AS total_transactions,
    ROUND(
        (
            (COUNT(sa.id) / NULLIF(TIMESTAMPDIFF(MONTH, cu.enabled_at, CURDATE()), 0)) * 12 * (0.001 * AVG(sa.confirmed_amount) / 100)
        ),
        2
    ) AS estimated_clv
FROM clean_users cu
LEFT JOIN savings_savingsaccount sa ON cu.id = sa.owner_id
WHERE cu.enabled_at IS NOT NULL
GROUP BY cu.id, cu.name, cu.enabled_at
ORDER BY estimated_clv DESC;