/*****************************************************************

UNION LEGACY TABLE TO NEW TABLE

Goal: 
A table of event speakers has been migrated from a legacy 
database to a new database. It should be unioned to the current
table of event speakers to get a collection of all current and 
historical event speakers. The result should be saved as a table.

SQL Concepts Used:
- UNION
- Table creation
- CASE Statements

*****************************************************************/

CREATE OR REPLACE TABLE EVENT_SPEAKERS
AS
with Leg AS (
    SELECT
        ID,
        ACCOUNT_ID
        FIRST_NAME,
        LAST_NAME,
        PRESENTATION_ORDER,
        PRESENTATION_TIME,
        PRESENTATION_TITLE,
        SESSION_DATE,
        STATUS,
        EVENT_CITY,
        EVENT_CODE,
        EVENT_COUNTRY,
        EVENT_TITLE,
        EVENT_TYPE,
        INVITED_AS,
        NOTES
    FROM LEGACY_SPEAKERS
),
Cur AS (
    SELECT
        ID,
        ACCOUNT_ID,
        FIRST_NAME,
        LAST_NAME,
        PRESENTATION_ORDER,
        PRESENTATION_TIME,
        PRESENTATION_TITLE,
        SESSION_DATE,
        STATUS,
        EVENT_CITY,
        EVENT_CODE,
        EVENT_COUNTRY,
        EVENT_TITLE,
        EVENT_TYPE,
        INVITED_AS,
        NOTES
    FROM SPEAKERS
),
Un AS (
    SELECT 
        * 
    FROM Leg 
    UNION ALL 
    SELECT 
        * 
    FROM Cur
)
SELECT 
    *, 
    CASE 
        WHEN Un.INVITED_AS IS NULL THEN '' 
        ELSE Un.INVITED_AS 
    END AS FINAL_ROLE
FROM Un;