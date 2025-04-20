/******************************************************

TOP DONORS FROM COMPANY A

Goal:
Determine the total donation amount of every employee from Company A who has donated at least $100.
Return their ID, email, and donation total, and sort by donation total (highest first).

SQL Concepts Used:
- INNER JOIN
- Subqueries
- HAVING

******************************************************/

SELECT
    CON."Id",
    CON."Email",
    SUM(DON."Amount")
FROM CONTACTS AS CON
    JOIN DONATIONS AS DON --inner join, as we only need to return individuals with donation records
        ON CON."Id" = DON."CONTACT_ID"
WHERE CON."Account_Id" IN (SELECT "Id" FROM ACCOUNTS WHERE "Name" = 'Company A') --since we don't need columns from ACCOUNTS, a subquery is fine                                                                                                                                                                                                                                                                             
GROUP BY 1, 2
HAVING SUM(DON."Amount") >= 100 --return only individuals who have donated at least 100
ORDER BY 3 DESC;
