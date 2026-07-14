-- ==========================================
-- SQL Data Transformation and Cleaning
-- Domain: Banking Credit Risk Analytics
-- Description: Contains scripts for preprocessing, data type 
--              alignment, handling nulls, and generating derived 
--              business logic columns (Engagement tenure, Income bands, 
--              and Processing fees) equivalent to the DAX schema.
-- ==========================================

-- 1. Create a cleaned/processed view of client banking data
CREATE OR REPLACE VIEW view_processed_client_banking AS
SELECT 
    client_id,
    name,
    age,
    location_id,
    
    -- Cast Joined Bank string to Date type (handles potential formats)
    CAST(joined_bank AS DATE) AS joined_bank_date,
    
    -- Calculate Engagement Tenure (Days and Years)
    -- In T-SQL: DATEDIFF(day, joined_bank, GETDATE())
    -- In PostgreSQL: CURRENT_DATE - CAST(joined_bank AS DATE)
    (CURRENT_DATE - CAST(joined_bank AS DATE)) AS engagement_days,
    ROUND((CURRENT_DATE - CAST(joined_bank AS DATE)) / 365.25, 2) AS engagement_years,
    
    banking_contact,
    nationality,
    occupation,
    fee_structure,
    loyalty_classification,
    estimated_income,
    
    -- Income Discretization (Bucketing)
    CASE 
        WHEN estimated_income < 100000.00 THEN 'Low'
        WHEN estimated_income >= 100000.00 AND estimated_income < 300000.00 THEN 'Mid'
        ELSE 'High'
    END AS income_band,
    
    -- Processing Fee Rate Structure
    CASE 
        WHEN fee_structure = 'High' THEN 0.05
        WHEN fee_structure = 'Mid' THEN 0.03
        WHEN fee_structure = 'Low' THEN 0.01
        ELSE 0.00
    END AS processing_fee_rate,
    
    superannuation_savings,
    amount_of_credit_cards,
    credit_card_balance,
    bank_loans,
    bank_deposits,
    checking_accounts,
    saving_accounts,
    foreign_currency_account,
    business_lending,
    properties_owned,
    risk_weighting,
    
    -- Calculate Total Portfolio Balances
    (bank_loans + business_lending + credit_card_balance) AS total_loan_exposure,
    (bank_deposits + saving_accounts + checking_accounts + foreign_currency_account) AS total_deposit_liquidity,
    
    br_id,
    gender_id,
    ia_id
FROM fact_client_banking;

-- 2. Data Cleaning Check Queries (Standard QA tests)

-- Find rows with negative balances (anomalies)
SELECT client_id, name, bank_loans, bank_deposits 
FROM fact_client_banking 
WHERE bank_loans < 0 OR bank_deposits < 0 OR credit_card_balance < 0;

-- Identify duplicate clients
SELECT client_id, COUNT(*) 
FROM fact_client_banking 
GROUP BY client_id 
HAVING COUNT(*) > 1;

-- Check distribution of null values across crucial fields
SELECT 
    SUM(CASE WHEN client_id IS NULL THEN 1 ELSE 0 END) AS null_id,
    SUM(CASE WHEN estimated_income IS NULL THEN 1 ELSE 0 END) AS null_income,
    SUM(CASE WHEN risk_weighting IS NULL THEN 1 ELSE 0 END) AS null_risk
FROM fact_client_banking;
