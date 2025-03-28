SELECT "SALESFORCE ID", COUNT(*) FROM PRODUCTION.MART_MEMBERSHIP_HISTORY.MEMBERSHIP_DATA_TERM_BACKUP 
WHERE "Transaction Id" IS NULL 
    AND "TERM YEAR" <= YEAR(CURRENT_DATE()) + 1 
    AND "SALESFORCE ID" IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" NOT LIKE '%yopmail.com%')
GROUP BY 1
ORDER BY 2 DESC;

SELECT "ITEM NAME", COUNT(*) FROM PRODUCTION.MART_MEMBERSHIP_HISTORY.MEMBERSHIP_DATA_TERM_BACKUP 
WHERE "Transaction Id" IS NULL 
    AND "TERM YEAR" <= YEAR(CURRENT_DATE()) + 1 
    AND "SALESFORCE ID" IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" NOT LIKE '%yopmail.com%')
GROUP BY 1
ORDER BY 2 DESC;

--"current year" transaction id? excluse emeritus?
--Filter out test accounts

SELECT "Id", "Name", "Email", "Member_Type__c" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Id" = --
;


SELECT * FROM PRODUCTION.MART_MEMBERSHIP_HISTORY.MEMBERSHIP_DATA_TERM_BACKUP WHERE "SALESFORCE ID" = --
;

--Create a view that merges membership information with contact info track mem-related transactions
--create or replace view TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE
--as
WITH AdjustedMembership AS (
    SELECT 
        m.*,
        -- Adjust month forward if transaction is after the snapshot date in the same month
        CASE 
            WHEN m."Transaction Date" > cs.CONVERTED_SNAPSHOT_DATE
            THEN DATEADD(MONTH, 1, m."Transaction Date")
            ELSE m."Transaction Date"
        END AS ADJUSTED_DATE
    FROM PRODUCTION.MART_MEMBERSHIP_HISTORY.MEMBERSHIP_HISTORY_FINAL m
        LEFT JOIN TEST.CONTACT_SNAPSHOTS.FINAL_CONTACT_SNAPSHOT_WITH_OM cs 
            ON m."SALESFORCE ID" = cs."Id"
            AND DATE_TRUNC('MONTH', m."Transaction Date") = DATE_TRUNC('MONTH', cs.CONVERTED_SNAPSHOT_DATE)
)
SELECT cs.*, am.*
FROM TEST.CONTACT_SNAPSHOTS.FINAL_CONTACT_SNAPSHOT_WITH_OM AS cs
    LEFT JOIN AdjustedMembership am 
        ON cs."Id" = am."SALESFORCE ID"
        AND DATE_TRUNC('MONTH', cs.CONVERTED_SNAPSHOT_DATE) = DATE_TRUNC('MONTH', am.ADJUSTED_DATE);


SELECT * FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE LIMIT 1000;

SELECT COUNT(*) FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE
WHERE "Transaction Id" IS NULL;

/*
Churn Case 1:
Was pushed: paid thru date changed with no transaction id
Query: Find all the records indicating a member was pushed

If previous paid thru date <> current paid thru date
    AND current treansaction id IS NULL THEN 'Pushed'

 */
with Pushed AS (
    SELECT 
        *,
        LAG(CSM."Paid_thru_date__c") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Transaction Id") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE AS CSM
)
SELECT COUNT(DISTINCT AACR_ID) FROM Pushed 
WHERE "Paid_thru_date__c" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "Transaction Id" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" LIKE '%yopmail.com%') --filtering out test accounts
    AND "Member_Type__c" <> 'Emeritus Member'
;

--Find number of times each member has been pushed
with Pushed AS (
    SELECT 
        *,
        LAG(CSM."Paid_thru_date__c") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Transaction Id") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE AS CSM
)
SELECT
    "AACR_ID",
    COUNT(*) 
FROM Pushed 
WHERE "Paid_thru_date__c" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "Transaction Id" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" LIKE '%yopmail.com%') --filtering out test accounts
    AND "Member_Type__c" <> 'Emeritus Member'
GROUP BY 1
ORDER BY 2 DESC
;

SELECT "Name" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Id" = --; --testing someone who apparently was pushed 9 times (not sure that's possible)
--Check on this member, what do the push records actually look like?
with Pushed AS (
    SELECT 
        *,
        LAG(CSM."Paid_thru_date__c") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Transaction Id") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE AS CSM
)
SELECT
    *
FROM Pushed 
WHERE "Paid_thru_date__c" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "Transaction Id" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" LIKE '%yopmail.com%') --filtering out test accounts
    AND "Member_Type__c" <> 'Emeritus Member'
    AND "Id" = --
;

/*
Churn Case 2:
How many people go from operating to non-operating?
This happens YoY? Does the time actually matter? 
 */

with OffRoles AS (
    SELECT 
        *,
        LAG(CSM."Paid_thru_date__c") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Final_Membership_Status") OVER(PARTITION BY CSM."AACR_ID" ORDER BY CSM."Paid_thru_date__c") AS PREVIOUS_OM_STATUS
    FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE AS CSM
)
SELECT
    AACR_ID,
    COUNT(*)
FROM OffRoles 
WHERE "Paid_thru_date__c" <> PREVIOUS_PAID_THRU_DATE
    AND PREVIOUS_OM_STATUS = 'Operating Member' AND "Final_Membership_Status" = 'Non-operating Member'
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.REPL_SALESFORCE_OWNBACKUP.CONTACT WHERE "Email" LIKE '%yopmail.com%') --filtering out test accounts
    AND "Member_Type__c" <> 'Emeritus Member'
GROUP BY 1
ORDER BY 2 DESC
; --this gives list of members who have fallen off roles at some point. 

SELECT DISTINCT "Title" FROM TEST.CONTACT_SNAPSHOTS.CS_MEMBERSHIP_MERGE WHERE AACR_ID = --
; --this person had a title change, interesting!
--Find out how many of these members have switched jobs (>1 title or >1 accountid)


