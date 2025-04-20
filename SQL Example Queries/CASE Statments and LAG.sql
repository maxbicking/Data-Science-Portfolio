/*****************************************************************

CASE STATEMENTS WITH LAG

Goal:
A table of contacts has been snapshotted at regular intervals 
and UNIONed. This table is called Merged. Create a VIEW 
that contains all columns from 
Merged and 3 columns:
- If a contact's Title has changed, then label "Title Change"
- If a contact's membership status chsnges from "OM" to 
    "Non-OM", then the contact has churned
- If a contact's PAID_THRU_DATE has changed with 
    no SALES_NUMBER, then the contact has been "Pushed"

SQL Concepts Used:
- LAG
- CASE statements
- CTEs
- Creation of Views/Tables

 *****************************************************************/

CREATE OR REPLACE VIEW MERGED_FINAL
AS
with CH AS (
    SELECT 
        "ID",
        PAID_THRU_DATE,
        MEMBERSHIP_STATUS,
        DATE_OF_SNAPSHOT,
        LAG(Merged.PAID_THRU_DATE) OVER(PARTITION BY Merged."ID" ORDER BY Merged.PAID_THRU_DATE) AS PREVIOUS_PAID_THRU_DATE,
        LAG(Merged.MEMBERSHIP_STATUS) OVER(PARTITION BY Merged."ID" ORDER BY Merged.PAID_THRU_DATE) AS PREVIOUS_OM_STATUS
    FROM Merged
),
PSH AS (
    SELECT 
        "ID",
        PAID_THRU_DATE,
        SALES_NUMBER,
        DATE_OF_SNAPSHOT,
        LAG(Merged.PAID_THRU_DATE) OVER(PARTITION BY Merged."ID" ORDER BY Merged.PAID_THRU_DATE) AS PREVIOUS_PAID_THRU_DATE,
        LAG(Merged.SALES_NUMBER) OVER(PARTITION BY Merged."ID" ORDER BY Merged.PAID_THRU_DATE) AS PREVIOUS_TRANSACTION_ID
    FROM Merged
)
SELECT
    Merged.*,
    CASE 
        WHEN TC.PREVIOUS_SNAPSHOT_DATE <> Merged.DATE_OF_SNAPSHOT AND TC.PREVIOUS_TITLE <> Merged."Title" THEN 'Title Change'
    END AS TITLE_CHANGE,
    CASE 
        WHEN CH.PREVIOUS_PAID_THRU_DATE <> Merged.PAID_THRU_DATE
            AND CH.PREVIOUS_OM_STATUS = 'OM' AND Merged.MEMBERSHIP_STATUS = 'Non-OM' THEN 'Churned'
    END AS CHURNED,
    CASE
        WHEN PSH.PREVIOUS_PAID_THRU_DATE <> Merged.PAID_THRU_DATE AND Merged.SALES_NUMBER IS NULL THEN 'Pushed'
    END AS PUSHED
FROM Merged
    LEFT JOIN TC 
        ON Merged."ID" = TC."ID" AND Merged.DATE_OF_SNAPSHOT = TC.DATE_OF_SNAPSHOT
    LEFT JOIN CH
        ON Merged."ID" = CH."ID" AND Merged.DATE_OF_SNAPSHOT = CH.DATE_OF_SNAPSHOT
    LEFT JOIN PSH
        ON Merged."ID" = PSH."ID" AND Merged.DATE_OF_SNAPSHOT = PSH.DATE_OF_SNAPSHOT;