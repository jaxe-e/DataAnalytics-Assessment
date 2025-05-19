# DataAnalytics-Assessment 

This document provides an overview and explanation of a set of SQL queries designed to analyze customer data in a financial institution. The queries focus on customer segmentation, transaction behavior, account activity, and customer lifetime value estimation.

Each question addresses a specific business need, and the queries demonstrate how to extract actionable insights from the database.

### Per-Question Explanations

#### Assessment Q1: High-Value Customers with Multiple Products

**Objective:** Identify customers who have both a savings and an investment plan.

**Approach:**

1. The query joins the `clean_users`, `savings_savingsaccount`, and `plans_plan` tables to link customer information with their savings and investment accounts.
2. It filters for investment plans using `pl.is_a_fund = 1`.
3. It counts the distinct savings accounts and investment plans for each customer using `COUNT(DISTINCT sa.id)` and `COUNT(DISTINCT CASE WHEN pl.is_a_fund = 1 THEN pl.id END)`.
4. It calculates the total deposits for each customer using `SUM(sa.confirmed_amount)`.
5. It filters for customers with at least one savings account and one investment plan using a `HAVING` clause.
6. The results are ordered by total deposits in descending order, using the `ROUND` function to format numeric results for better readability.

**Rationale:** This approach efficiently identifies customers who have diversified their investments with the institution, indicating higher value and potential for further engagement.

#### Assessment Q2: Transaction Frequency Analysis

**Objective:** Analyze customer transaction frequency and categorize them into high, medium, and low frequency users.

**Approach:**

1. A subquery calculates the average number of transactions per customer per month.
2. The main query categorizes customers based on their average monthly transactions using a `CASE` statement.
3. The results are grouped by frequency category, and the count of customers in each category is provided.
4. The results are ordered by frequency category.

**Rationale:** This analysis helps segment customers based on their activity levels, allowing for targeted marketing and resource allocation.

#### Assessment Q3: Account Inactivity Alert

**Objective:** Flag accounts with no inflow transactions for over one year.

**Approach:**

1. The query uses Common Table Expressions (CTEs) to organize the data retrieval:
    * `plan_transactions`: Selects plan details and joins with savings accounts to get transaction dates, filtering for funded plans and getting the last transaction date for each plan.
    * `savings_transactions`: Selects savings account details and gets the last transaction date for each savings account.
    * `user_accounts`: Selects user ID and activation date (`enabled_at`) from `clean_users`.
2. The `user_accounts` CTE is joined with the `plan_transactions` and `savings_transactions` CTEs using `LEFT JOIN` on the user ID.
3. The query filters for accounts where the last transaction date is more than one year prior to the current date.
4. The query also filters for users who have an activation date.
5. It returns the owner ID, account type, last transaction date, and inactivity days.

**Rationale:** Identifying inactive accounts is crucial for risk management, customer re-engagement, and operational efficiency. The use of `COALESCE` is essential here to handle potential null values when joining tables and calculating the last transaction dates.

#### Assessment Q4: Customer Lifetime Value (CLV) Estimation

**Objective:** Estimate the Customer Lifetime Value (CLV) for each customer.

**Approach:**

1. The query calculates the account tenure in months since signup.
2. It counts the total number of transactions for each customer.
3. It estimates CLV using a simplified formula:  
    * CLV = (Average Transactions per Month) × 12 × Average Profit per Transaction  
    * Where Average Profit per Transaction is assumed to be 0.1% of the average transaction value.
4. The results are ordered by estimated CLV in descending order.

**Rationale:** CLV estimation helps prioritize customer segments, evaluate marketing investments, and understand the long-term value of customer relationships.

### Challenges

* **Understanding the Data Model:** The primary challenge was fully understanding the relationships between tables and the meaning of each column.
* **Ensuring Accuracy:** It was crucial to ensure the accuracy of calculations, especially in the CLV estimation and transaction frequency analysis.
* **Handling Null Values:** The use of `COALESCE` was essential to handle potential null values when joining tables and calculating last transaction dates, preventing errors or incomplete data.

---
