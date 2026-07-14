-- ==========================================
-- SQL DDL: Database Schema Definition
-- Domain: Banking Credit Risk Analytics
-- Target System: PostgreSQL / SQL Server Compatible
-- Description: Establishes a relational star schema
--              linking client transactional metrics
--              to reference dimension tables.
-- ==========================================

-- 1. Dimension Table: Gender Reference
CREATE TABLE dim_gender (
    gender_id INT PRIMARY KEY,
    gender VARCHAR(10) NOT NULL UNIQUE
);

-- 2. Dimension Table: Banking Relationship Types
CREATE TABLE dim_banking_relationship (
    br_id INT PRIMARY KEY,
    banking_relationship VARCHAR(50) NOT NULL UNIQUE
);

-- 3. Dimension Table: Investment Advisors
CREATE TABLE dim_investment_advisor (
    ia_id INT PRIMARY KEY,
    investment_advisor VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Fact Table: Client Banking and Credit Profiles
CREATE TABLE fact_client_banking (
    client_id VARCHAR(50) PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    age INT CHECK (age >= 18 AND age <= 120),
    location_id INT NOT NULL,
    joined_bank DATE NOT NULL,
    banking_contact VARCHAR(100),
    nationality VARCHAR(100) NOT NULL,
    occupation VARCHAR(150) NOT NULL,
    fee_structure VARCHAR(50) CHECK (fee_structure IN ('High', 'Mid', 'Low')),
    loyalty_classification VARCHAR(50) CHECK (loyalty_classification IN ('Jade', 'Gold', 'Silver', 'Platinum')),
    estimated_income DECIMAL(15, 2) NOT NULL,
    superannuation_savings DECIMAL(15, 2) DEFAULT 0.00,
    amount_of_credit_cards INT DEFAULT 0,
    credit_card_balance DECIMAL(15, 2) DEFAULT 0.00,
    bank_loans DECIMAL(15, 2) DEFAULT 0.00,
    bank_deposits DECIMAL(15, 2) DEFAULT 0.00,
    checking_accounts DECIMAL(15, 2) DEFAULT 0.00,
    saving_accounts DECIMAL(15, 2) DEFAULT 0.00,
    foreign_currency_account DECIMAL(15, 2) DEFAULT 0.00,
    business_lending DECIMAL(15, 2) DEFAULT 0.00,
    properties_owned INT DEFAULT 0,
    risk_weighting INT CHECK (risk_weighting >= 1 AND risk_weighting <= 5),
    br_id INT NOT NULL,
    gender_id INT NOT NULL,
    ia_id INT NOT NULL,
    
    -- Foreign Key Constraints
    CONSTRAINT fk_client_relationship FOREIGN KEY (br_id) REFERENCES dim_banking_relationship(br_id),
    CONSTRAINT fk_client_gender FOREIGN KEY (gender_id) REFERENCES dim_gender(gender_id),
    CONSTRAINT fk_client_advisor FOREIGN KEY (ia_id) REFERENCES dim_investment_advisor(ia_id)
);

-- 5. Query Optimization Indexes
CREATE INDEX idx_client_risk ON fact_client_banking(risk_weighting);
CREATE INDEX idx_client_loyalty ON fact_client_banking(loyalty_classification);
CREATE INDEX idx_client_nationality ON fact_client_banking(nationality);
CREATE INDEX idx_client_joined ON fact_client_banking(joined_bank);
