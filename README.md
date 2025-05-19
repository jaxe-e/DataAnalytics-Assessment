# DataAnalytics-Assessment

This project contains SQL queries developed to analyze user transaction data across savings and investment products. The analysis supports business teams such as Marketing, Finance, and Operations with data-driven insights into user behavior, transaction patterns, inactivity risks, and lifetime value estimations.

---

## 🔍 Questions and Approaches

### 1. High-Value Customers with Multiple Products

**Scenario:** Identify users with both a funded savings account and a funded investment plan.

**Approach:**  
- Joined the `clean_users`, `savings_savingsaccount`, and `plans_plan` tables.  
- Filtered `plans_plan` to include only investment plans (`is_a_fund = 1`).  
- Used `HAVING` to ensure users have at least one savings and one investment plan.  
- Aggregated total confirmed deposits from savings accounts and converted from kobo to naira using `ROUND(SUM(...) / 100, 2)`.

---

### 2. Transaction Frequency Analysis

**Scenario:** Classify customers based on how frequently they transact each month.

**Approach:**  
- Calculated months of activity using the `enabled_at` date.  
- Counted total transactions per user using `savings_savingsaccount`.  
- Derived average monthly transactions using a subquery.  
- Segmented users into:
  - High Frequency: ≥10 transactions/month  
  - Medium Frequency: 3–9 transactions/month  
  - Low Frequency: <3 transactions/month

---

### 3. Account Inactivity Alert

**Scenario:** Flag active users with no inflow transactions for over one year.

**Approach:**  
- Created two CTEs to fetch the most recent transaction dates from savings and investment accounts.  
- Used `COALESCE()` to merge transaction history.  
- Selected users with `enabled_at` and last activity older than 365 days.  
- Labeled account type as either "Savings" or "Investment" based on available data.

---

### 4. Customer Lifetime Value (CLV) Estimation

**Scenario:** Estimate user lifetime value based on tenure and average profit per transaction.

**Approach:**  
- Used a simplified CLV formula:  
CLV = (Total Transactions ÷ Tenure in Months) × 12 × (0.1% × Avg Transaction Value)
- Converted transaction values from kobo to naira using `/100`.  
- Rounded the final CLV to 2 decimal places.  
- Ordered users by estimated CLV to identify the most valuable customers.

---

## ⚠️ Kobo to Naira Conversion Notes

Although values are stored in kobo, I **did not perform in-place conversion** using `UPDATE` statements. Instead, conversion from kobo to naira is handled within the `SELECT` queries using division by 100. This decision was made to avoid unintentional side effects in the database.

---

## 🧩 Challenges Faced

- **Kobo to Naira Conversion:**  
Originally planned to update values directly with SQL `UPDATE`, but chose to handle conversion only in SELECT queries for safety.

- **Handling NULL and Zero Values:**  
Users with missing `enabled_at` values were excluded from time-based metrics. Also ensured division-by-zero was handled using `NULLIF`.

- **Join Logic for Inactivity:**  
Creating a unified view of last transaction dates across savings and investment accounts required careful join logic using `COALESCE`.

- **Frequency Classification Thresholds:**  
Defined clear and business-relevant thresholds to segment customers accurately based on transaction habits.

---

## ✅ Summary

This SQL project demonstrates practical business intelligence techniques to answer common operational and marketing questions using raw transaction data. By leveraging JOINs, aggregates, date functions, and conditional logic, I delivered clean insights into customer engagement, product usage, and profitability.

---
