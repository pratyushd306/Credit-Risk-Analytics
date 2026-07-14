-- ==========================================
-- SQL Portfolio KPI and Analytics Calculations
-- Domain: Banking Credit Risk Analytics
-- Description: Queries matching the business requirements and 
--              PowerBI KPI formulations, including loan portfolio 
--              mix, deposit concentration, and risk distribution.
-- ==========================================

-- 1. Global High-Level Portfolio KPI Summary
SELECT 
    COUNT(DISTINCT client_id) AS total_clients,
    
    -- Loan Metrics
    SUM(bank_loans) AS total_bank_loans,
    SUM(business_lending) AS total_business_lending,
    SUM(credit_card_balance) AS total_credit_card_balance,
    SUM(bank_loans + business_lending + credit_card_balance) AS total_loan_exposure,
    
    -- Deposit Metrics
    SUM(bank_deposits) AS total_bank_deposits,
    SUM(saving_accounts) AS total_savings_balance,
    SUM(checking_accounts) AS total_checking_balance,
    SUM(foreign_currency_account) AS total_fx_balance,
    SUM(bank_deposits + saving_accounts + checking_accounts + foreign_currency_account) AS total_deposit_liquidity,
    
    -- Fee and Engagement Metrics
    SUM((bank_loans + business_lending + credit_card_balance) * 
        CASE 
            WHEN fee_structure = 'High' THEN 0.05
            WHEN fee_structure = 'Mid' THEN 0.03
            WHEN fee_structure = 'Low' THEN 0.01
            ELSE 0.00
        END
    ) AS total_calculated_processing_fees,
    
    AVG(CURRENT_DATE - CAST(joined_bank AS DATE)) AS avg_client_tenure_days
FROM fact_client_banking;


-- 2. Credit Risk Concentration by Demographic and Segment
SELECT 
    risk_weighting,
    COUNT(client_id) AS client_count,
    ROUND(COUNT(client_id) * 100.0 / SUM(COUNT(client_id)) OVER(), 2) AS pct_client_share,
    SUM(bank_loans + business_lending + credit_card_balance) AS total_loans_exposed,
    AVG(estimated_income) AS avg_estimated_income
FROM fact_client_banking
GROUP BY risk_weighting
ORDER BY risk_weighting DESC;


-- 3. Loan-to-Deposit Ratio (LDR) and Leverage by Income Band
SELECT 
    CASE 
        WHEN estimated_income < 100000.00 THEN 'Low'
        WHEN estimated_income >= 100000.00 AND estimated_income < 300000.00 THEN 'Mid'
        ELSE 'High'
    END AS income_band,
    COUNT(client_id) AS total_clients,
    SUM(bank_loans + business_lending + credit_card_balance) AS total_loans,
    SUM(bank_deposits + saving_accounts + checking_accounts + foreign_currency_account) AS total_deposits,
    -- Calculate Loan-to-Deposit Ratio (LDR)
    ROUND(
        SUM(bank_loans + business_lending + credit_card_balance) / 
        NULLIF(SUM(bank_deposits + saving_accounts + checking_accounts + foreign_currency_account), 0)
    , 4) AS loan_to_deposit_ratio
FROM fact_client_banking
GROUP BY 
    CASE 
        WHEN estimated_income < 100000.00 THEN 'Low'
        WHEN estimated_income >= 100000.00 AND estimated_income < 300000.00 THEN 'Mid'
        ELSE 'High'
    END
ORDER BY total_loans DESC;


-- 4. Geographic & Regional Exposure Summary (Nationality)
SELECT 
    nationality,
    COUNT(client_id) AS total_clients,
    SUM(bank_loans) AS total_retail_bank_loans,
    SUM(business_lending) AS total_commercial_business_lending,
    SUM(bank_loans + business_lending + credit_card_balance) AS cumulative_exposure,
    ROUND(SUM(bank_loans + business_lending + credit_card_balance) * 100.0 / 
          SUM(SUM(bank_loans + business_lending + credit_card_balance)) OVER(), 2) AS pct_exposure_share
FROM fact_client_banking
GROUP BY nationality
ORDER BY cumulative_exposure DESC;


-- 5. Private Banking vs. Retail / Institutional Risk Weight Profiles
SELECT 
    r.banking_relationship,
    COUNT(c.client_id) AS client_count,
    AVG(c.risk_weighting) AS avg_risk_weighting,
    SUM(c.bank_loans + c.business_lending + c.credit_card_balance) AS total_loans,
    SUM(c.bank_deposits + c.saving_accounts + c.checking_accounts + c.foreign_currency_account) AS total_deposits
FROM fact_client_banking c
JOIN dim_banking_relationship r ON c.br_id = r.br_id
GROUP BY r.banking_relationship
ORDER BY total_loans DESC;
