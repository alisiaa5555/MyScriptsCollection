-- I wrote some queries to pull out information from my database to check my expenses.

--I joined "Expenses" table with "ExpenseType" and "Accounts" tables to be able to see account names and expense type names instead of seeing just numbers in "Expenses" table.

SELECT TOP (1000) 
        e.ExpenseID, e.Date, e.Amount, e.ExpenseTypeID, et.ExpenseTypeName, e.Comments, a.AccountName, e.AccountID
        FROM Expenses as e
        INNER JOIN ExpenseType as et ON e.ExpenseTypeID = et.ExpenseTypeID
        INNER JOIN Accounts as a ON e.AccountID = a.AccountID order by Date asc;



-- I wrote a monthly spending breakdown by account and expense type for June 2025

select ac.accountName, et.ExpenseTypeName, sum(exp.Amount) as TotalAmount from Expenses as exp
inner join ExpenseType as et on et.ExpenseTypeID = exp.ExpenseTypeID
inner join Accounts as ac on ac.AccountID = exp.AccountID
where exp.Date Between '2025-06-01' and '2025-06-30' group by ac.AccountName, et.ExpenseTypeName order by ac.AccountName, et.ExpenseTypeName;



-- I wrote a statament to select a sum for specific date and group by account name and expense type name

select sum(exp.Amount) as SUM, a.AccountName, t.ExpenseTypeName from Expenses as exp
inner join ExpenseType as t on exp.ExpenseTypeID = t.ExpenseTypeID
inner join Accounts as a on exp.AccountID = a.AccountID 
where exp.Date = '2025-07-03' group by a.AccountName, t.ExpenseTypeName;



/*
I wrote a categorized report showing total spending grouped by account.
I add a column called "SpendingLevel" based on the total amount:
'Low' if total is less than 100.
'Medium' if total is between 100 and 500.
'High' if total is above 500.
The report returns:
  - AccountName
  - TotalAmount
  - SpendingLevel
*/

SElECT ac.accountName, sum(exp.Amount) AS TotalAmount,
CASE
    WHEN sum(exp.Amount) < 100 THEN 'Low'
    WHEN sum(exp.Amount) between 100 and 500 THEN 'Medium'
    ELSE 'High'
END AS SpendingLevel
FROM Expenses as exp
INNER JOIN Accounts as ac on ac.AccountID = exp.AccountID group by ac.AccountName;
