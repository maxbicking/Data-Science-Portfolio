/***********************************************************

MEETING ATTENDANCE WITH DONATION HISTORY

Goal: 
- Display all participation records for a given EVENT_ID
- For every attendee, display their donation history (total amount given, number of donations, most recent donation)

SQL Concepts Used:
- JOINs
- CTEs (including recursive CTEs)
- Aggregate functions (SUM, COUNT)
- Window functions (ROW_NUMBER with PARTITION BY)
- Datamarts

 ***********************************************************/

with DonationTotal AS ( --calculate the total number of donations by conact
    SELECT
        CONTACT_ID,
        SUM("AMOUNT") AS TOTAL_AMOUNT,
        COUNT("ID") AS NUMBER_OF_DONATIONS
    FROM DONATIONS
    GROUP BY 1
),
Recent AS ( --find the amount and date of the most recent donation of each contact 
    SELECT
        CONTACT_ID,
        DONATION_DATE AS DATE_OF_MOST_RECENT_DONATION,
        ROW_NUMBER() OVER(PARTITION BY CONTACT_ID ORDER BY DONATION_DATE DESC) AS ROW_ORDER, 
            --label all contact records with a row number ordered by donation date (most recent 1st). will later pull only top row as most recent
        "AMOUNT" AS MOST_RECENT_DONATION_AMOUNT
    FROM DONATIONS
),
MostRecent AS ( --row order 1 finds top result
    SELECT 
        *
    FROM Recent
    WHERE ROW_ORDER = 1
)
SELECT
    MR.*,
    CON."ID",
    MostRecent.MOST_RECENT_DONATION_AMOUNT AS MOST_RECENT_DONATION_AMOUNT,
    MostRecent.DATE_OF_MOST_RECENT_DONATION AS DATE_OF_MOST_RECENT_DONATION,
    DonationTotal.TOTAL_AMOUNT AS TOTAL_DONATION_AMOUNT,
    DonationTotal.NUMBER_OF_DONATIONS AS NUMBER_OF_DONATIONS
FROM MART_REGISTRATIONS AS MR
    LEFT JOIN CONTACTS AS CON
        ON MR.CONTACT_ID = CON."ID"
    LEFT JOIN MostRecent
        ON CON."ID" = MostRecent.CONTACT_ID
    LEFT JOIN DonationTotal
        ON CON."ID" = DonationTotal.CONTACT_ID
    LEFT JOIN EVENTS AS EV
        ON MR.EVENT_ID = EV."ID"
WHERE MR.EVENT_ID = 'abcd1234';