Select [Name] from Departments

Select FirstName,MiddleName,LastName from Employees

Select FirstName + '.' + LastName + '@softuni.bg' As [Full Email Address] from Employees

Select DISTINCT Salary from Employees


Select * from Employees
Where JobTitle = 'Sales Representative'

Select FirstName,LastName,JobTitle from Employees
Where Salary between 20000 and 30000

Select CONCAT(FirstName,' ',MiddleName,' ',LastName)
As [Full Name]
from Employees
Where Salary in (25000,14000,12500,23600)

Select FirstName,LastName from Employees
Where ManagerID is null

Select FirstName,LastName,Salary from Employees
Where Salary > 50000
Order By Salary Desc

Select Top(5) FirstName,LastName from Employees
Order By Salary Desc

Select FirstName,LastName from Employees
Where DepartmentID != 4

Select * from Employees
Order By Salary Desc,
       FirstName Asc,
	   LastName Desc,
	   MiddleName Asc

Create View [V_EmployeesSalaries] As 
Select FirstName,LastName,Salary from Employees



Create View [V_EmployeeNameJobTitle] As
Select CONCAT(FirstName,' ',MiddleName,' ',LastName) As [Full Name],JobTitle As [Job Title] From Employees

Select Distinct JobTitle from Employees As [JobTitle]

Select TOP(10) * from Projects
Order By StartDate Asc , [Name] Asc

Select Top(7) FirstName,LastName,HireDate from Employees
Order By HireDate DESC

Update [Employees]
Set [Salary] += 0.12 * [Salary]
Where [DepartmentID] in (1,2,4,11)

Select [Salary] from Employees 



Select PeakName from Peaks
Order By PeakName ASC

Select Top(30) CountryName,[Population] from Countries
Where ContinentCode = 'EU'
Order By [Population] DESC, CountryName ASC

Select CountryName,CountryCode,Case CurrencyCode
When 'EUR' Then 'Euro' Else 'Not Euro'
End
AS Currency
From Countries
Order By CountryName ASC


Select [Name] from Characters
Order By [Name] ASC
