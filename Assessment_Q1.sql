-- Question 1: High-Value Customers with Multiple Products
-- Scenario: The business wants to identify customers who have both a savings and an investment plan (cross-selling opportunity).
-- Task: Write a query to find customers with at least one funded savings plan AND one funded investment plan, sorted by total deposits.
SELECT
    cu.id AS owner_id,
    cu.name,
    COUNT(DISTINCT sa.id) AS savings_count,
    COUNT(DISTINCT CASE WHEN pl.is_a_fund = 1 THEN pl.id END) AS investment_count,
    ROUND(SUM(sa.confirmed_amount) / 100, 2) AS total_deposits
FROM clean_users cu
LEFT JOIN savings_savingsaccount sa ON cu.id = sa.owner_id
LEFT JOIN plans_plan pl ON cu.id = pl.owner_id
WHERE pl.is_a_fund = 1
GROUP BY cu.id, cu.name
HAVING COUNT(DISTINCT sa.id) >= 1
   AND COUNT(DISTINCT CASE WHEN pl.is_a_fund = 1 THEN pl.id END) >= 1
ORDER BY total_deposits DESC;