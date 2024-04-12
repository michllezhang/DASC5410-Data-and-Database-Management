
-- Creating tables for user account, purchase, and address data
-- Create functions and inster data  for user account, purchase, and address data
-- Test case
-- Assignment 1
-- Mengyang Zhang
-- Last modification date: 2023-10-29 01:45:33.385
-- tables
-- table: MYZ_ADDRESS

CREATE TABLE MYZ_ADDRESS (
    ADDRESS_ID int GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    address_line_1 varchar2(256) NOT NULL,
    address_line_2 varchar2(256) NULL,
    user_account_id int NULL,
    CONSTRAINT MYZ_ADDRESS_pk PRIMARY KEY (ADDRESS_ID)
);


-- Table: MYZ_PURCHASE
CREATE TABLE MYZ_PURCHASE (
    PURCHASE_ID int GENERATED AS IDENTITY (START WITH 1 INCREMENT BY 1) NOT NULL,
    purchase_date timestamp  NOT NULL,
    user_account_id int  NOT NULL,
    delivery_address_id int  NOT NULL,
    total_price number(19,2)  NOT NULL,
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
-- FK_0 (table: MYZ_ADDRESS)
ALTER TABLE MYZ_ADDRESS ADD CONSTRAINT FK_0
    FOREIGN KEY (user_account_id)
    REFERENCES MYZ_USER_ACCOUNT (USER_ID);

-- FK_1 (table: MYZ_PURCHASE)
ALTER TABLE MYZ_PURCHASE ADD CONSTRAINT FK_1
    FOREIGN KEY (user_account_id)
    REFERENCES MYZ_USER_ACCOUNT (USER_ID);

-- FK_2 (table: MYZ_PURCHASE)
ALTER TABLE MYZ_PURCHASE ADD CONSTRAINT FK_2
    FOREIGN KEY (delivery_address_id)
    REFERENCES MYZ_ADDRESS (ADDRESS_ID);




CREATE OR REPLACE PROCEDURE ADD_USER(
    p_user_name IN VARCHAR2,
    p_email IN VARCHAR2,
    p_password IN VARCHAR2
) AS
    v_salt VARCHAR2(50);
    v_hashed_password RAW(256);
BEGIN
    v_salt := DBMS_RANDOM.STRING('A', 10);

    SELECT STANDARD_HASH(TO_CHAR(p_password || v_salt), 'SHA1')
    INTO v_hashed_password
    FROM dual;

    INSERT INTO MYZ_USER_ACCOUNT(user_name, email, password, password_salt)
    VALUES (p_user_name, p_email, v_hashed_password, v_salt);

END ADD_USER;
/

BEGIN
    ADD_USER('Mengyang Zhang', 'zhangm21@mytru.ca', '87654321');
END;
/

INSERT INTO MYZ_ADDRESS (address_line_1, address_line_2, user_account_id)
VALUES ('666 Main Rd', 'House 103', 1);
INSERT INTO MYZ_PURCHASE (purchase_date, user_account_id, delivery_address_id, total_price)
VALUES (SYSTIMESTAMP, 1, 1, 50.00);



CREATE OR REPLACE FUNCTION AUTH_USER(
    p_user_name IN VARCHAR2,
    p_password  IN VARCHAR2
) RETURN VARCHAR2 AS
    v_stored_salt        VARCHAR2(50);
    v_stored_hashed_pass RAW(256);
    v_new_hashed_pass    RAW(256);
BEGIN

    SELECT password_salt, password
    INTO v_stored_salt, v_stored_hashed_pass
    FROM MYZ_USER_ACCOUNT
    WHERE user_name = p_user_name;


    SELECT STANDARD_HASH(TO_CHAR(p_password || v_stored_salt), 'SHA1')
    INTO v_new_hashed_pass
    FROM dual;


    IF v_new_hashed_pass = v_stored_hashed_pass THEN
        RETURN 'Successful';
    ELSE
        RETURN 'Failed';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Can Not Found User';
    WHEN OTHERS THEN
        RETURN 'Error';
END AUTH_USER;
/


CREATE OR REPLACE PROCEDURE SHOW_PURCHASE(p_user_name IN VARCHAR2, p_password IN VARCHAR2) AS
    v_stored_salt        VARCHAR2(50);
    v_stored_hashed_pass RAW(256);
    v_new_hashed_pass    RAW(256);

    CURSOR purchase_cursor IS
    SELECT u.user_name, p.purchase_date,
           a.address_line_1 || ' ' || NVL(a.address_line_2, '') AS delivery_address,
           p.total_price
    FROM MYZ_PURCHASE p
    JOIN MYZ_USER_ACCOUNT u ON p.user_account_id = u.USER_ID
    JOIN MYZ_ADDRESS a ON p.delivery_address_id = a.ADDRESS_ID
    WHERE u.user_name = p_user_name;

    v_purchase purchase_cursor%ROWTYPE;

BEGIN

    SELECT password_salt, password
    INTO v_stored_salt, v_stored_hashed_pass
    FROM MYZ_USER_ACCOUNT
    WHERE user_name = p_user_name;

    -- Create a new hash using the provided password and the retrieved salt
    SELECT STANDARD_HASH(TO_CHAR(p_password || v_stored_salt), 'SHA1')
    INTO v_new_hashed_pass
    FROM dual;

    -- Check password
    IF v_new_hashed_pass = v_stored_hashed_pass THEN
        OPEN purchase_cursor;
        LOOP
            FETCH purchase_cursor INTO v_purchase;
            EXIT WHEN purchase_cursor%NOTFOUND;

            -- Purchase data
            DBMS_OUTPUT.PUT_LINE('-----------------');
            DBMS_OUTPUT.PUT_LINE('User name is ' || v_purchase.user_name);
            DBMS_OUTPUT.PUT_LINE('Purchase date is ' || v_purchase.purchase_date);
            DBMS_OUTPUT.PUT_LINE('Delivery address is ' || v_purchase.delivery_address);
            DBMS_OUTPUT.PUT_LINE('Total price is ' || v_purchase.total_price);
            DBMS_OUTPUT.PUT_LINE('-----------------');
        END LOOP;

        CLOSE purchase_cursor;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Password Invalid');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Can Not Found User');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END SHOW_PURCHASE;
/


BEGIN
    SHOW_PURCHASE('ANNA', '999999');
END;

BEGIN
    SHOW_PURCHASE('Mengyang Zhang', '87654321');
END;
/
