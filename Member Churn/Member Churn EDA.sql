/*
EDA

These queries have been anonymized to maintain data privacy and integrity. 

####################################################

Main Priorities:

1. Determine who has churned
    a. Who has fallen off roles?
    b. Who has been pushed through without upgrade?

2. Write queries to join fields from other relevant tables, i.e. transactions

3. Construct case statements for any formulaic fields

 */

SELECT "ID", COUNT(*) FROM PRODUCTION.MEMBERSHIP.MEMBERSHIP_ALL_YEARS
WHERE "TRANSACTION_ID" IS NULL 
    AND "TERM_YEAR" <= YEAR(CURRENT_DATE()) + 1 
    AND "ID" IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" NOT LIKE '%testmail.com%') --filtering out test accounts
GROUP BY 1
ORDER BY 2 DESC;

SELECT "ITEM NAME", COUNT(*) FROM PRODUCTION.MEMBERSHIP.MEMBERSHIP_ALL_YEARS
WHERE "TRANSACTION_ID" IS NULL 
    AND "TERM_YEAR" <= YEAR(CURRENT_DATE()) + 1 
    AND "ID" IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" NOT LIKE '%testmail.com%')
GROUP BY 1
ORDER BY 2 DESC;

--"current year" TRANSACTION_ID? exclude Lifetime Hon. Members?
--Filter out test accounts

SELECT "Id", "Name", "Email", "MEMBER_TYPE" FROM PRODUCTION.DBO.CONTACT WHERE "Id" = --
;


SELECT * FROM PRODUCTION.MEMBERSHIP.MEMBERSHIP_ALL_YEARS WHERE "ID" = --
;

--Create a view that merges membership information with contact info track mem-related transactions
CREATE OR REPLACE VIEW TEST.CONTACT_MERGE.CM_MEMBERSHIP
AS
TH AdjustedMembership AS (
    SELECT 
        m.*,
        -- Adjust month forward if transaction is after the snapshot date in the same month
        CASE 
            WHEN m."TRANSACTION_DATE" > cs.CONVERTED_SNAPSHOT_DATE
            THEN DATEADD(MONTH, 1, m."TRANSACTION_DATE")
            ELSE m."TRANSACTION_DATE"
        END AS ADJUSTED_DATE
    FROM PRODUCTION.MEMBERSHIP.MEMBERSHIP_ALL_YEARS m
        LEFT JOIN TEST.CONTACT_MERGE.CM_FINAL cs 
            ON m."ID" = cs."Id"
            AND DATE_TRUNC('MONTH', m."TRANSACTION_DATE") = DATE_TRUNC('MONTH', cs.CONVERTED_SNAPSHOT_DATE)
)
SELECT cs.*, am.*
FROM TEST.CONTACT_MERGE.CM_FINAL AS cs
    LEFT JOIN AdjustedMembership am 
        ON cs."Id" = am."ID"
        AND DATE_TRUNC('MONTH', cs.CONVERTED_SNAPSHOT_DATE) = DATE_TRUNC('MONTH', am.ADJUSTED_DATE);


SELECT * FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP LIMIT 1000;

SELECT COUNT(*) FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP
WHERE "TRANSACTION_ID" IS NULL;

/*
Churn Case 1:
Was pushed: paid thru date changed with no TRANSACTION_ID
Query: Find all the records indicating a member was pushed

If previous paid thru date <> current paid thru date
    AND current treansaction id IS NULL THEN 'Pushed'

GET: List of ID's of members who have been pushed; PUSHED

 */
with Pushed AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."TRANSACTION_ID") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
)
SELECT COUNT(DISTINCT ID) FROM Pushed 
WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "TRANSACTION_ID" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
    AND "MEMBER_TYPE" <> 'Lifetime Hon. Member' --filter out honorary members who have no transactions associated with membership, but have lifetime terms
;

--Find number of times each member has been pushed
with Pushed AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."TRANSACTION_ID") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
)
SELECT
    "ID",
    COUNT(*) 
FROM Pushed 
WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "TRANSACTION_ID" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
    AND "MEMBER_TYPE" <> 'Lifetime Hon. Member'
GROUP BY 1
ORDER BY 2 DESC
;

SELECT "Name" FROM PRODUCTION.DBO.CONTACT WHERE "Id" = --; --testing someone who apparently was pushed 9 times (not sure that's possible)
--Check on this member, what do the push records actually look like?

with Pushed AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."TRANSACTION_ID") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
)
SELECT
    *
FROM Pushed 
WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
    AND "TRANSACTION_ID" IS NULL --current trans id is null
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
    AND "MEMBER_TYPE" <> 'Lifetime Hon. Member'
    AND "Id" = --
;

/*
Churn Case 2:
How many people go from operating to non-operating?
This happens YoY? Does the time actually matter? 

GET: List of people who have fallen off roles; OFF_ROLES

 */

with OffRoles AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Final_Membership_Status") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_OM_STATUS
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
)
SELECT
    ID,
    COUNT(*)
FROM OffRoles 
WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE
    AND PREVIOUS_OM_STATUS = 'Operating Member' AND "Final_Membership_Status" = 'Non-operating Member'
    AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
    AND "MEMBER_TYPE" <> 'Lifetime Hon. Member'
GROUP BY 1
ORDER BY 2 DESC
; --this gives list of members who have fallen off roles at some point. 

SELECT DISTINCT "Title" FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP WHERE ID = --
; --this person had a title change, interesting!
--Find out how many of these members have switched jobs (>1 title or >1 accountid)


/*
Columns to Add:

--First, figure out which columns from contact to keep

--Engagement score

--Opportunities (most recent, total)--contact opportunity merge exists already

--Title change (CTE probably)

--Meeting attendance

--PUSHED (Bool) = ID in PUSHED

--OFF_ROLES (Bool) = ID in OFF_ROLES

--CHURN (Bool) = ID in PUSHED or ID in OFF_ROLES
    Or make these two separate datasets

 */

/*
Will create a contact activity table in TEST that has both donation info and meeting attendance info

 */

SELECT * FROM TEST.CONTACT_MERGE.ALL_ACTIVITY LIMIT 1000; --big merge table with snapshots of contact table take monthly over last 6 years

with TitleChange AS (
    SELECT
        DISTINCT "Id"
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP
    GROUP BY 1
    HAVING COUNT(DISTINCT "Title") > 1 OR COUNT(DISTINCT "AccountId") > 1
),
Pushed1 AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."TRANSACTION_ID") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_TRANSACTION_ID
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
),
Pushed2 AS ( 
    SELECT
        DISTINCT "Id"
    FROM Pushed1 
    WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE --change in paid thru date
        AND "TRANSACTION_ID" IS NULL --current trans id is null
        AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
        AND "MEMBER_TYPE" <> 'Lifetime Hon. Member'
),
OffRoles1 AS (
    SELECT 
        *,
        LAG(CSM."PAID_THRU_DATE") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_PAID_THRU_DATE,
        LAG(CSM."Final_Membership_Status") OVER(PARTITION BY CSM."ID" ORDER BY CSM."PAID_THRU_DATE") AS PREVIOUS_OM_STATUS
    FROM TEST.CONTACT_MERGE.CM_MEMBERSHIP AS CSM
),
OffRoles2 AS (
    SELECT
        DISTINCT "Id"
    FROM OffRoles1 
    WHERE "PAID_THRU_DATE" <> PREVIOUS_PAID_THRU_DATE
        AND PREVIOUS_OM_STATUS = 'Operating Member' AND "Final_Membership_Status" = 'Non-operating Member'
        AND "Id" NOT IN (SELECT "Id" FROM PRODUCTION.DBO.CONTACT WHERE "Email" LIKE '%testmail.com%') --filtering out test accounts
        AND "MEMBER_TYPE" <> 'Lifetime Hon. Member'
)
SELECT
    CASE WHEN "Id" IN (SELECT "Id" FROM TitleChange) THEN 1 ELSE 0 END AS "TITLE_CHANGE",
    CASE WHEN "Id" IN (SELECT "Id" FROM Pushed2) THEN 1 ELSE 0 END AS "PUSHED",
    CASE WHEN "Id" IN (SELECT "Id" FROM OffRoles2) THEN 1 ELSE 0 END AS "CHURNED",
    *
FROM TEST.CONTACT_MERGE.ALL_ACTIVITY;




