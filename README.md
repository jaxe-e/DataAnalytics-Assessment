# DataAnalytics-Assessment 

This repository contains SQL queries to address the data analysis questions provided in the assessment. The queries are organized as follows:

DataAnalytics-Assessment/
│
├── Assessment_Q1.sql
├── Assessment_Q2.sql
├── Assessment_Q3.sql
├── Assessment_Q4.sql
│
└── README.md

## Data Cleaning Explanation

Before addressing the specific questions, I performed some data cleaning to ensure the `users_customuser` table was suitable for analysis.  Here's a breakdown of the `data cleaning.sql` script:

```sql
CREATE TEMPORARY TABLE clean_users AS
SELECT 
    -- Keep all original columns except `name`, which we update below
    id,
    email,
    first_name,
    last_name,
    phone_number,
    signup_device,
    enabled_at,
    last_login,

    -- Cleaned name column (digits stripped, proper case, fallback from email if needed)
    CONCAT(
        -- Cleaned first name
        CASE
            WHEN (TRIM(first_name) = '' OR first_name IS NULL)
                 AND (TRIM(last_name) = '' OR last_name IS NULL)
                 AND LOCATE('+', email) > 0
            THEN CONCAT(
                UPPER(LEFT(REGEXP_REPLACE(SUBSTRING_INDEX(email, '+', 1), '[0-9]', ''), 1)),
                LOWER(SUBSTRING(REGEXP_REPLACE(SUBSTRING_INDEX(email, '+', 1), '[0-9]', ''), 2))
            )
            ELSE CONCAT(
                UPPER(LEFT(REGEXP_REPLACE(first_name, '[0-9]', ''), 1)),
                LOWER(SUBSTRING(REGEXP_REPLACE(first_name, '[0-9]', ''), 2))
            )
        END,
        ' ',
        -- Cleaned last name
        CASE
            WHEN (TRIM(first_name) = '' OR first_name IS NULL)
                 AND (TRIM(last_name) = '' OR last_name IS NULL)
                 AND LOCATE('+', email) > 0
            THEN CONCAT(
                UPPER(LEFT(REGEXP_REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(email, '@', 1), '+', -1), '[0-9]', ''), 1)),
                LOWER(SUBSTRING(REGEXP_REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(email, '@', 1), '+', -1), '[0-9]', ''), 2))
            )
            ELSE CONCAT(
                UPPER(LEFT(REGEXP_REPLACE(last_name, '[0-9]', ''), 1)),
                LOWER(SUBSTRING(REGEXP_REPLACE(last_name, '[0-9]', ''), 2))
            )
        END
    ) AS name

FROM users_customuser
WHERE email LIKE '%@cowrywise.com%'
  AND email REGEXP '\\.com$';
````
### 🧹 Explanation

#### **Temporary Table Creation**

A temporary table `clean_users` is created. This allows us to perform the data cleaning steps without altering the original `users_customuser` table and makes subsequent queries more readable.

#### **Column Selection**

All original columns from `users_customuser` are included, except for the `name` column, which is regenerated.

#### **Name Cleaning Logic**

The core of the script focuses on cleaning the `name` column. It handles cases where first or last names are missing or contain digits:

- **Missing Name Handling**: If both `first_name` and `last_name` are empty or null, the code extracts the name from the email address (assuming a format like `firstname+lastname@cowrywise.com`). It uses `LOCATE`, `SUBSTRING_INDEX`, and `REGEXP_REPLACE` to achieve this.

- **Digit Removal**: The `REGEXP_REPLACE` function removes any digits from the `first_name` and `last_name` columns.

- **Proper Case Conversion**: The `UPPER` and `LOWER` functions are used to convert the names to proper case (e.g., "John Doe").

#### **Filtering**

The script filters the `users_customuser` table to only include users with a valid company email.

This cleaning process ensures that the `name` column is consistently formatted and free of extraneous characters, which is crucial for accurate reporting in the subsequent queries.

---

### 📌 Per-Question Explanations

#### **Assessment Q1: High-Value Customers with Multiple Products**

**Approach:**

- Joined the `clean_users`, `savings_savingsaccount`, and `plans_plan` tables to link customer information with their savings accounts and plans.
- Used `COUNT(DISTINCT ...)` to count distinct savings accounts and investment plans. Used `CASE WHEN` to count only plans where `is_a_fund = 1`.
- Filtered for customers having at least one savings account and one investment plan using a `HAVING` clause.
- Calculated total deposits with `SUM(sa.confirmed_amount)` and converted from kobo to naira.
- Ordered the results by `total_deposits` in descending order.

**Challenges:**

- Ensuring only investment plans were counted correctly with conditional logic.
- Handling the kobo to naira conversion consistently.

---

#### **Assessment Q2: Transaction Frequency Analysis**

**Approach:**

- Joined `clean_users` and `savings_savingsaccount`.
- Calculated the total number of transactions per customer and their active months using `TIMESTAMPDIFF`.
- Computed the average transactions per month.
- Used a `CASE` statement to categorize customers into:
  - "High Frequency"
  - "Medium Frequency"
  - "Low Frequency"
- Grouped results by frequency category and counted users in each.

**Challenges:**

- Preventing division by zero with `NULLIF` when calculating averages.
- Accurately computing average monthly transactions.

---

#### **Assessment Q3: Account Inactivity Alert**

**Approach:**

- Used Common Table Expressions (CTEs) for better query organization.
- Created CTEs for the last transaction date per savings and investment account.
- Joined CTEs with `clean_users`.
- Filtered accounts where the last transaction date was over a year ago using `DATE_SUB` and `DATEDIFF`.
- Included both savings and investment accounts.

**Challenges:**

- Merging results from both account types into one result set.
- Correctly calculating inactive days.

---

#### **Assessment Q4: Customer Lifetime Value (CLV) Estimation**

**Approach:**

- Joined `clean_users` and `savings_savingsaccount`.
- Calculated tenure in months using `TIMESTAMPDIFF`.
- Counted total transactions.
- Applied CLV formula: CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction. I assumed avg_profit_per_transaction is 0.1% of the average transaction value.

**Challenges:**

- Implementing the CLV formula accurately.
- Handling potential division by zero in the CLV calculation using `NULLIF`.
- Calculating the average transaction value and applying the profit percentage.

---
