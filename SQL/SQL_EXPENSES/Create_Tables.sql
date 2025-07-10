USE ExpensesDB;

-- First of all, I created an "Accounts" table with "AccountID" and "AccountName" columns.
CREATE TABLE Accounts (
	AccountID INT IDENTITY(1,1) PRIMARY KEY,
	AccountName NVARCHAR(100) NOT NULL
);

-- I inserted values into "Accounts" table.
Insert into Accounts (AccountName) values ('XXX'),('YYY'),('ZZZZ'),('NNNN');
-- Then, I dadded a new "Owner" column as during table creations I decided to add an additional one. 
Alter table Accounts 
	ADD Owner NVARCHAR(100);

--I updated rows in the "Owner" column.
UPDATE Accounts
SET Owner = 'LOLO' WHERE AccountName in ('XXX', 'YYY');

UPDATE Accounts
SET Owner = 'LALA' WHERE AccountName in ('ZZZZ', 'NNNN');


-- Next, I created an "ExpenseType" table with "ExpenseTypeID" and "ExpenseTypeName" columns.
CREATE TABLE ExpenseType (
	ExpenseTypeID INT IDENTITY(1,1) PRIMARY KEY,
	ExpenseTypeName NVARCHAR(100) NOT NULL
);

-- I inserted values into "ExpenseType" table.
Insert into ExpenseType (ExpenseTypeName) values ('Treats'),('Clothes'),('FastFood'),('Fees'),('Savings'),('Subscriptions'),('Other');

-- Next, I created an "Expenses" table with "ExpenseID", "Date", "Amount", "ExpenseTypeID", "AccountID" and "Comments" column. "AccountID" and "ExpenseTypeID" are foreign keys referencing columns in Accounts and ExpenseType tables.
CREATE TABLE Expenses (
	ExpenseID INT IDENTITY(1,1) PRIMARY KEY,
	Date DATE NOT NULL,
	Amount DECIMAL(10,2) NOT NULL,
	ExpenseTypeID INT NOT NULL,
	AccountID INT NOT NULL,
	Comments NVARCHAR(255),
	FOREIGN KEY (AccountID) REFERENCES Accounts (AccountID),
	FOREIGN KEY (ExpenseTypeID) REFERENCES ExpenseType(ExpenseTypeID)
	);


--At the very end I added a contraint to avoid adding the same expense twice.
ALTER TABLE Expenses
ADD CONSTRAINT UQ_Expenses_UniqueEntry
UNIQUE (Date, Amount, ExpenseTypeID, AccountID);
