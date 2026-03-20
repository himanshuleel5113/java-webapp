-- First ensure we're using the right database
CREATE DATABASE IF NOT EXISTS himdata;
USE himdata;

-- Drop tables in correct order (to avoid foreign key issues)
DROP TABLE IF EXISTS TRANSACTIONS;
DROP TABLE IF EXISTS LOAN_APPLICATIONS;
DROP TABLE IF EXISTS ACCOUNTS;
DROP TABLE IF EXISTS USERS;

-- Create USERS table
CREATE TABLE USERS (
                       USER_ID INT AUTO_INCREMENT PRIMARY KEY,
                       FIRST_NAME VARCHAR(255) NOT NULL,
                       LAST_NAME VARCHAR(255) NOT NULL,
                       AADHAAR_NO VARCHAR(12) UNIQUE NOT NULL,
                       EMAIL VARCHAR(255) UNIQUE NOT NULL,
                       PASSWORD_HASH VARCHAR(255) NOT NULL,
                       CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create ACCOUNTS table
CREATE TABLE ACCOUNTS (
                          ACCOUNT_NO INT PRIMARY KEY,
                          USER_ID INT,
                          ACCOUNT_TYPE ENUM('SAVINGS', 'CHECKING', 'LOAN') DEFAULT 'SAVINGS',
                          BALANCE DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
                          STATUS ENUM('ACTIVE', 'BLOCKED', 'CLOSED') DEFAULT 'ACTIVE',
                          FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE
);

-- Create LOAN_APPLICATIONS table with ALL required columns
CREATE TABLE LOAN_APPLICATIONS (
                                   ID INT AUTO_INCREMENT PRIMARY KEY,
                                   ACCOUNT_NO INT NOT NULL,
                                   LOAN_TYPE VARCHAR(50) NOT NULL,
                                   AMOUNT DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
                                   TENURE INT NOT NULL DEFAULT 1,
                                   PURPOSE TEXT,
                                   STATUS ENUM('PENDING', 'APPROVED', 'REJECTED') DEFAULT 'PENDING',
                                   APPLIED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                                   FOREIGN KEY (ACCOUNT_NO) REFERENCES ACCOUNTS(ACCOUNT_NO) ON DELETE CASCADE
);

-- Create TRANSACTIONS table
CREATE TABLE TRANSACTIONS (
                              ID INT AUTO_INCREMENT PRIMARY KEY,
                              SENDER_ACCOUNT INT NULL,
                              RECEIVER_ACCOUNT INT NULL,
                              AMOUNT DECIMAL(15, 2) NOT NULL,
                              TX_TYPE ENUM('TRANSFER', 'DEPOSIT', 'WITHDRAWAL') NOT NULL,
                              REMARK VARCHAR(255),
                              CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              FOREIGN KEY (SENDER_ACCOUNT) REFERENCES ACCOUNTS(ACCOUNT_NO),
                              FOREIGN KEY (RECEIVER_ACCOUNT) REFERENCES ACCOUNTS(ACCOUNT_NO)
);

-- Show all tables to verify
SHOW TABLES;