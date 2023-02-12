Create Table Logs(
LogId INT PRIMARY KEY IDENTITY,
AccountId INT Foreign Key REFERENCES AccountHolders(Id),
OldSum Decimal(18,4) NOT NULL,
NewSum Decimal(18,4) NOT NULL
)

GO

Create Trigger tr_AddNewLog
On Accounts FOR UPDATE 
AS
   Begin
         Insert Into Logs(AccountId,OldSum,NewSum)
		 Select i.AccountHolderId,d.Balance,i.Balance
		   From inserted as i
		   Join deleted as d
		   On i.Id = d.Id
     End
GO

Create Table NotificationEmails(
Id INT PRIMARY KEY IDENTITY,
Recipient INT FOREIGN KEY REFERENCES AccountHolders(Id),
[Subject] NVARCHAR(60) NOT NULL,
Body NVARCHAR(100) NOT NULL
)

Go

Create Trigger tr_NotificationTrigger
ON Logs FOR INSERT
AS
  Begin
        Insert into NotificationEmails VALUES
		(
			(Select AccountId From inserted),
			(Select 'Balance change for account: ' + CAST([AccountId] AS VARCHAR(255)) FROM inserted),
			(Select 'On ' + FORMAT(GETDATE(), 'MMM dd yyyy h:mmtt') + 
								  ' your balance was changed from ' + 
									 CAST([OldSum] AS VARCHAR(255)) + 
															 ' to ' + 
									 CAST([NewSum] AS VARCHAR(255)) + 
															   '.' 
			 FROM inserted)

		 )
    End

Go

Create Proc usp_DepositMoney(@AccountId INT, @MoneyAmount DECIMAL(18,4))
AS
   Begin
         Update Accounts
		 Set Balance += @MoneyAmount
		 Where Id = @AccountId
     End
  
GO

Create Proc usp_WithdrawMoney (@AccountId INT, @MoneyAmount Decimal(18,4))
As
	  Begin
			 Update Accounts
			 Set Balance -= @MoneyAmount
			 Where Id = @AccountId
		 End

Go

Create Proc usp_TransferMoney(@SenderId INT, @ReceiverId INT, @Amount Decimal(18,4))
As
  Begin Transaction
         Exec dbo.usp_WithdrawMoney @SenderId, @Amount
		 Exec dbo.usp_DepositMoney @ReceiverId, @Amount
  Commit


Go


Create Proc usp_AssignProject(@emloyeeId INT, @projectID INT)
AS
  Begin
        DECLARE @projectsCount INT =
		(
		  Select Count(ProjectID)
		    From EmployeesProjects
			Where EmployeeID = @emloyeeId
		)

		If (@projectsCount >= 3)
		Begin
		RAISERROR('The employee has too many projects!',16,1)
		RollBack
		End

		Insert into EmployeesProjects Values(
		@emloyeeId,
		@projectID
		)

    END

Go

Create Table Deleted_Employees(
EmployeeId INT Primary Key,
FirstName NVARCHAR(50) NOT NULL,
LastName  NVARCHAR(50) NOT NULL,
MiddleName  NVARCHAR(50) NOT NULL,
JobTitle  NVARCHAR(50) NOT NULL,
DepartmentId INT NOT NULL,
Salary Decimal(18,4) NOT NULL
)

GO

Create Trigger tr_AddDeletedEmployeesToDeletedTable
ON Employees FOR DELETE
AS
  Begin
       Insert Into Deleted_Employees(FirstName,LastName,MiddleName,JobTitle,DepartmentId,Salary)
	   Select d.FirstName,d.LastName,d.MiddleName,d.JobTitle,d.DepartmentID,d.Salary
	   from deleted as d
    END


	DECLARE @userGameId INT = 
(
  SELECT ug.[Id]
  FROM [UsersGames] AS [ug] 
  JOIN [Users] AS [u] ON ug.[UserId] = u.[Id]
  JOIN [Games] AS [g] ON ug.[GameId] = g.[Id]
  WHERE u.[Username] = 'Stamat' AND g.[Name] = 'Safflower'
)
DECLARE @itemsCost DECIMAL(18, 4)

-- Buying items within 11-12 level range:

DECLARE @minLevel INT = 11
DECLARE @maxLevel INT = 12
DECLARE @playerCash DECIMAL(18, 4) = 
(
	SELECT [Cash]
    FROM [UsersGames]
    WHERE [Id] = @userGameId
)

SET @itemsCost = 
(
	SELECT SUM(Price)
    FROM [Items]
    WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
)

IF (@playerCash >= @itemsCost)
BEGIN
	BEGIN TRANSACTION
    UPDATE [UsersGames]
    SET [Cash] -= @itemsCost
    WHERE [Id] = @userGameId
      
    INSERT INTO [UserGameItems] (ItemId, UserGameId)
    (
		SELECT
			[Id],
			@userGameId
		FROM [Items]
		WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
	)
	COMMIT     
END

-- Buying items within 19-21 level range:

SET @minLevel = 19
SET @maxLevel = 21
SET @playerCash = 
(
	SELECT [Cash]
    FROM [UsersGames]
    WHERE [Id] = @userGameId
)

SET @itemsCost = 
(
	SELECT SUM(Price)
    FROM [Items]
    WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
)

IF (@playerCash >= @itemsCost)
BEGIN
	BEGIN TRANSACTION
    UPDATE [UsersGames]
    SET [Cash] -= @itemsCost
    WHERE [Id] = @userGameId
      
    INSERT INTO [UserGameItems] (ItemId, UserGameId)
    (
		SELECT
			[Id],
			@userGameId
		FROM [Items]
		WHERE [MinLevel] BETWEEN @minLevel AND @maxLevel
	)
	COMMIT     
END

-- Selecting result table:

SELECT i.[Name] AS [Item Name]
FROM [UserGameItems] AS [ugi]
JOIN [Items] AS [i] ON i.[Id] = ugi.[ItemId]
JOIN [UsersGames] AS [ug] ON ug.[Id] = ugi.[UserGameId]
JOIN [Games] AS [g] ON g.[Id] = ug.[GameId]
WHERE g.[Name] = 'Safflower'
ORDER BY [Item Name]
