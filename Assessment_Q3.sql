-- Question 3: Account Inactivity Alert
-- Scenario: The ops team wants to flag accounts with no inflow transactions for over one year.
-- Task: Find all active accounts (savings or investments) with no transactions in the last 1 year (365 days).
-- Find all active plans with no inflow transactions in the last 1 year
WITH plan_transactions AS (
    SELECT
        pl.owner_id,
        MAX(sa.created_on) AS last_plan_transaction
    FROM plans_plan pl
    JOIN savings_savingsaccount sa ON pl.owner_id = sa.owner_id
    WHERE pl.is_a_fund = 1
    GROUP BY pl.owner_id
),
savings_transactions AS (
    SELECT
        sa.owner_id,
        MAX(sa.created_on) AS last_savings_transaction
    FROM savings_savingsaccount sa
    WHERE  sa.owner_id IN (SELECT sa.owner_id from savings_savingsaccount)
    GROUP BY sa.owner_id
),
user_accounts AS (
    SELECT
        cu.id AS user_id,
        cu.enabled_at
    FROM clean_users cu
)
SELECT
    COALESCE(pt.owner_id, st.owner_id) AS owner_id,
    CASE
        WHEN pt.owner_id IS NOT NULL THEN 'Investment'
        WHEN st.owner_id IS NOT NULL THEN 'Savings'
    END AS account_type,
    DATE(COALESCE(pt.last_plan_transaction, st.last_savings_transaction)) AS last_transaction_date,
    DATEDIFF(CURDATE(), COALESCE(pt.last_plan_transaction, st.last_savings_transaction)) AS inactivity_days
FROM user_accounts u
LEFT JOIN plan_transactions pt ON u.user_id = pt.owner_id
LEFT JOIN savings_transactions st ON u.user_id = st.owner_id
WHERE COALESCE(pt.last_plan_transaction, st.last_savings_transaction) < DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
AND u.enabled_at IS NOT NULL;