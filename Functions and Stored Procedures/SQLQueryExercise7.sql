Create Proc usp_GetEmployeesSalaryAbove35000
AS
  Begin
        Select FirstName,
		        LastName
		from Employees
		Where Salary > 35000
	End


Exec dbo.usp_GetEmployeesSalaryAbove35000

GO

Create Proc usp_GetEmployeesSalaryAboveNumber @number DECIMAL(18,4)
AS
  Begin
		 Select FirstName,
				 LastName
	     from Employees
		 Where Salary >= @number
    End


Exec dbo.usp_GetEmployeesSalaryAboveNumber 48100

GO

Create Proc usp_GetTownsStartingWith (@letter VARCHAR(50))
AS
  Begin
          Select [Name] AS Town
		    from Towns
		   Where SUBSTRING([Name],1,Len(@letter)) = @letter
    End



Exec dbo.usp_GetTownsStartingWith 'b'


GO


Create PROC usp_GetEmployeesFromTown @townName VARCHAR(50)
AS
  Begin
        Select e.FirstName,
		       e.LastName
		  from Employees AS e
		  Join Addresses AS a
		  On e.AddressID = a.AddressID
		  Join Towns AS t
		  On t.TownID = a.TownID
		  Where t.[Name] = @townName
    End


Exec dbo.usp_GetEmployeesFromTown 'Sofia'


Go


Create FUNCTION ufn_GetSalaryLevel (@salary DECIMAL(18,4))
Returns NVARCHAR(10)
AS
   Begin

         Declare @salaryLevel NVARCHAR(10)

         If @salary < 30000
		 Set @salaryLevel = 'Low'

		 Else If @salary Between 30000 AND 50000
		 Set @salaryLevel = 'Average'

		 Else
		 Set @salaryLevel = 'High'

		 Return @salaryLevel
     End

GO



Create Proc usp_EmployeesBySalaryLevel @levelOfSalary NVARCHAR(10)
AS
   Begin
         Select FirstName,
		         LastName
		   from Employees
		   Where dbo.ufn_GetSalaryLevel(Salary) = @levelOfSalary
     End


Exec dbo.usp_EmployeesBySalaryLevel 'High'

Go

Create Function ufn_IsWordComprised(@setOfLetters VARCHAR(50), @word VARCHAR(50))
RETURNS BIT
         AS
		   Begin
		         Declare @index INT = 1

				 While(@index <= LEN(@word))
				      Begin
					         Declare @currentChar CHAR = SUBSTRING(@word,@index,1)
							 IF CHARINDEX(@currentChar,@setOfLetters) = 0
							 Return 0

							 Set @index += 1
					    END

						Return 1
		     END



Go


Create Proc usp_DeleteEmployeesFromDepartment (@departmentId INT)
AS
  Begin
       Declare @employeesToDelete Table (Id INT)
	    Insert into @employeesToDelete
		     Select EmployeeID
			   from Employees
			  Where DepartmentID = @departmentId

			  Delete from EmployeesProjects
			  Where EmployeeID IN(
			                       Select * from @employeesToDelete
			                     )

              Alter Table Departments
			  Alter Column ManagerID INT

			  Update Departments
			     Set ManagerID = NULL
				 Where ManagerID In (
				                      Select * from @employeesToDelete
				                    )

              Update Employees
			     Set ManagerID = NULL
				 Where ManagerID In (
				                      Select * from @employeesToDelete
                                    )

              Delete from Employees
			  Where DepartmentID = @departmentId

			  Delete from Departments
			  Where DepartmentID = @departmentId

			  Select Count(*)
			  From Employees
			  Where DepartmentID = @departmentId

    End

Go

Create Proc usp_GetHoldersFullName
AS
  Begin
        Select CONCAT(FirstName, ' ', LastName) As [Full Name]
		  From AccountHolders
    END


Exec dbo.usp_GetHoldersFullName

Go

Create PROC usp_GetHoldersWithBalanceHigherThan @number DECIMAL(18,4)
AS
  Begin
        Select ah.FirstName,
		       ah.LastName
		  From AccountHolders As ah
		  Join (
		                 Select AccountHolderId,
						 Sum(Balance) As TotalMoney
						 From Accounts
						 Group By AccountHolderId

		       )AS a On ah.Id = a.AccountHolderId
			   Where TotalMoney > @number
		  Order By ah.FirstName,ah.LastName
    End


Go

Create Function ufn_CalculateFutureValue (@sum DECIMAL(18,4),@yearlyInterestRate FLOAT,@numberOfYears INT)
RETURNS DECIMAL(18,4)
AS
  Begin

		 RETURN @sum * POWER((1 + @yearlyInterestRate),@numberOfYears)

    End



GO


Create or Alter Proc usp_CalculateFutureValueForAccount (@acountId INT, @interestRate FLOAT)
As
  Begin
       Select ah.Id As [Account Id],
	          ah.FirstName As [First Name],
	          ah.LastName As [Last Name],
			  a.Balance As [Current Balance],
			  dbo.ufn_CalculateFutureValue(Balance,@interestRate,5) As [Balance in 5 years]
	     From AccountHolders As ah
		 Join Accounts As a
		 On a.AccountHolderId = ah.Id
		 Where a.Id = @acountId
    End

Exec dbo.usp_CalculateFutureValueForAccount 1,0.1

Go

Create Function ufn_CashInUsersGames (@name NVARCHAR(50))
Returns TABLE
           AS
       Return(

	   Select SUM(Cash)
	       As SumCash
	     From (
	           Select g.[Name],
			          ug.Cash,
					  Row_Number() Over(Order By ug.Cash Desc) 
				   As RowNumber
			     from UsersGames 
				   As ug
				 Join Games 
				   As g
				 On ug.GameId = g.Id
				 Where g.[Name] = @name
				) 
				As SubQuery
         Where RowNumber % 2 <> 0
	         )