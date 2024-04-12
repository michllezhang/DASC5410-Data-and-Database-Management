
-- Created by Vertabelo (http://vertabelo.com)
-- Creating tables for user account, purchase, and address data
-- Assignment 1
-- Mengyang Zhang
-- Last modification date: 2023-10-29 01:28:19.486

-- tables
-- Table: MYZ_ADDRESS
CREATE TABLE MYZ_ADDRESS (
    ADDRESS_ID int GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    address_line_1 varchar2(256)  NOT NULL,
    address_line_2 varchar2(256)  NULL,
    MYZ_USER_ACCOUNT_USER_ID int  NOT NULL,
    CONSTRAINT MYZ_ADDRESS_pk PRIMARY KEY (ADDRESS_ID)
) ;

-- Table: MYZ_PURCHASE
CREATE TABLE MYZ_PURCHASE (
    PURCHASE_ID int GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    purchase_date timestamp  NOT NULL,
    user_account_id int  NOT NULL,
    delivery_address_id int  NOT NULL,
    total_price number(9,2)  NOT NULL,
    CONSTRAINT MYZ_PURCHASE_pk PRIMARY KEY (PURCHASE_ID)
) ;

-- Table: MYZ_USER_ACCOUNT
CREATE TABLE MYZ_USER_ACCOUNT (
    USER_ID int GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    user_name varchar2(100)  NOT NULL,
    email varchar2(254)  NOT NULL,
    password raw(256)  NOT NULL,
    password_salt varchar2(50)  NULL,
    CONSTRAINT AK_0 UNIQUE (user_name),
    CONSTRAINT AK_1 UNIQUE (email),
    CONSTRAINT MYZ_USER_ACCOUNT_pk PRIMARY KEY (USER_ID)
) ;


-- foreign keys
-- FK_1 (table: MYZ_PURCHASE)
ALTER TABLE MYZ_PURCHASE ADD CONSTRAINT FK_1
    FOREIGN KEY (user_account_id)
    REFERENCES MYZ_USER_ACCOUNT (USER_ID);

-- FK_2 (table: MYZ_PURCHASE)
ALTER TABLE MYZ_PURCHASE ADD CONSTRAINT FK_2
    FOREIGN KEY (delivery_address_id)
    REFERENCES MYZ_ADDRESS (ADDRESS_ID);

-- MYZ_ADDRESS_MYZ_USER_ACCOUNT (table: MYZ_ADDRESS)
ALTER TABLE MYZ_ADDRESS ADD CONSTRAINT MYZ_ADDRESS_MYZ_USER_ACCOUNT
    FOREIGN KEY (MYZ_USER_ACCOUNT_USER_ID)
    REFERENCES MYZ_USER_ACCOUNT (USER_ID);
