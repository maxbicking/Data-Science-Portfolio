/******************************************************************

CALCULATE ENGAGEMENT SCORE

Goal:
Calculate the contact engagement score based on member status, login activity, 
donation history, and email clickE.

SQL Concepts Used:
- DATEDIFF
- CAST datetime to date
- CTEs
-LEFT JOINs
- CASE statements
- Calculated columns

******************************************************************/

WITH scored_contacts AS (
    SELECT
        CON.CONTACT_ID,

        /* --- Status Score -----------------------------------*/
        CASE
            WHEN CON.MEMBER_STATUS = 'A' THEN 100
            WHEN CON.MEMBER_STATUS = 'B' THEN 75
            WHEN CON.MEMBER_STATUS = 'C' THEN 50
            ELSE 0
        END AS status_score,

        /* --- Login Score ------------------------------------*/
        CASE
            WHEN CON.LAST_ACTIVITY_DATE IS NULL THEN 0
            WHEN DATEDIFF('day', CON.LAST_ACTIVITY_DATE, CURRENT_DATE) BETWEEN 1 AND 365 THEN 100
            WHEN DATEDIFF('day', CON.LAST_ACTIVITY_DATE, CURRENT_DATE) BETWEEN 366 AND 730 THEN 50
            ELSE 0
        END AS login_score,

        /* --- Donation Score ------------------------------*/
        CASE
            WHEN D.DATE_OF_MOST_RECENT_DONATION IS NULL THEN  0
            WHEN DATEDIFF('day', D.DATE_OF_MOST_RECENT_DONATION, CURRENT_DATE) BETWEEN 1 AND 365 THEN 100
            WHEN DATEDIFF('day', D.DATE_OF_MOST_RECENT_DONATION, CURRENT_DATE) BETWEEN 366 AND 730 THEN 50
            ELSE 0
        END AS donation_score,

        /* --- Email Score ------------------------------------*/
        CASE
            WHEN E.MOST_RECENT_CLICK_TIME IS NULL THEN  0
            WHEN DATEDIFF('day', CAST(E.MOST_RECENT_CLICK_TIME AS DATE), CURRENT_DATE) BETWEEN 1  AND 365 THEN 100
            WHEN DATEDIFF('day', CAST(E.MOST_RECENT_CLICK_TIME AS DATE), CURRENT_DATE) BETWEEN 366 AND 730 THEN 50
            ELSE 0
        END AS email_score
    FROM CONTACTS AS CON
        LEFT JOIN EMAILS AS E 
            ON E.CONTACT_ID = CON.ID
        LEFT JOIN DONATIONS AS D
            ON D.CONTACT_ID = CON.ID
)
--  Final SELECT adds the engagement_score (simple average)
SELECT
    *,
    (status_score + login_score + donation_score + email_score) / 4.0
        AS engagement_score
FROM scored_contacts;
