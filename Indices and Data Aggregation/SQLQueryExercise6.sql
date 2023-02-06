Select COUNT(*) from WizzardDeposits


Select MAX(MagicWandSize) As LongestMagicLand 
from WizzardDeposits

Select DepositGroup,
       MAX(MagicWandSize) As LongestMagicLand
from WizzardDeposits
Group By DepositGroup


Select Top(2) DepositGroup
from WizzardDeposits
Group By DepositGroup
Order By AVG(MagicWandSize)


Select DepositGroup,
       SUM(DepositAmount) As TotalSum
from WizzardDeposits
Group By DepositGroup


Select DepositGroup,
       SUM(DepositAmount) As TotalSum
from WizzardDeposits
Where MagicWandCreator = 'Ollivander family'
Group By DepositGroup


Select DepositGroup,
       SUM(DepositAmount) As TotalSum
from WizzardDeposits
Where MagicWandCreator = 'Ollivander family'
Group By DepositGroup
Having SUM(DepositAmount) < 150000
Order By TotalSum Desc


Select DepositGroup,
       MagicWandCreator,
	   MIN(DepositCharge) As MinDepositCharge
from WizzardDeposits
Group By DepositGroup, MagicWandCreator


Select [AgeGroup],
       COUNT(*) 
	AS WizardCount
  from(
		Select 
		 Case
			 When Age Between 0 AND 10 Then '[0-10]'
			 When Age Between 11 AND 20 Then '[11-20]'
			 When Age Between 21 AND 30 Then '[21-30]'
			 When Age Between 31 AND 40 Then '[31-40]'
			 When Age Between 41 AND 50 Then '[41-50]'
			 When Age Between 51 AND 60 Then '[51-60]'
			 Else '[61+]'
			  END 
			   As [AgeGroup]
			 from WizzardDeposits
	) As SubQueary
Group By AgeGroup


Select LEFT(FirstName,1) As FirstLetter
from WizzardDeposits
Where DepositGroup = 'Troll Chest'
Group By LEFT(FirstName,1)
Order By FirstLetter Asc

Select DepositGroup,
       IsDepositExpired,
	   AVG(DepositInterest) As AverageInterest
from WizzardDeposits
Where DepositStartDate > '01/01/1985'
Group By DepositGroup,IsDepositExpired
Order By DepositGroup Desc,
         IsDepositExpired Asc


Select SUM([Difference]) As SumDifference
from(
		Select FirstName As [Host Wizard],
			   DepositAmount As [Host Wizard Deposit],
			   LEAD(FirstName) OVER(Order By Id) As [Guest Wizard],
			   LEAD(DepositAmount) OVER(Order By Id) As [Guest Wizard Deposit],
			   DepositAmount - LEAD(DepositAmount) OVER(Order By Id) As [Difference]
		from WizzardDeposits
    ) As SubQueary




Select DepartmentID,
       SUM(Salary) As TotalSalary
from Employees
Group By DepartmentID


Select DepartmentId,
       MIN(Salary) As MinimumSalary
from Employees
Where DepartmentID IN (2,5,7) AND HireDate > '01/01/2000'
Group By DepartmentID



Select * 
Into NewEmployeesTable
from Employees
Where Salary > 30000

DELETE from NewEmployeesTable
Where ManagerID = 42

UPDATE NewEmployeesTable
   Set Salary+=5000
 Where DepartmentID = 1

 Select DepartmentID,
        AVG(Salary) As AverageSalary
 from NewEmployeesTable
 Group By DepartmentID


 Select DepartmentID,
        MAX(Salary) As MaxSalary
 from Employees
 Group By DepartmentID
 Having MAX(Salary) NOT BETWEEN 30000 AND 70000


 Select Count(*) As [Count] from Employees
 Where ManagerID IS NULL

 Select  DISTINCT DepartmentId,
        Salary AS ThirdHighestSalary
 from (
		Select DepartmentID,
					 Salary,
		Dense_Rank() Over(Partition By [DepartmentId] Order By Salary Desc) As SalaryRank
		from Employees
      ) As SubQueary
Where SalaryRank = 3


Select Top(10) e.FirstName,
               e.LastName,
			   e.DepartmentID
From Employees AS e
Where Salary > (
				Select AVG(Salary) AS AverageSalary
				From Employees AS eSub
				Where e.DepartmentID = eSub.DepartmentID
				Group By DepartmentID
               )
Order By e.DepartmentID