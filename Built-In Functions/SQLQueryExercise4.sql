Select FirstName,LastName from Employees
Where Left(FirstName,2) = 'Sa'

Select FirstName,LastName from Employees
Where CHARINDEX('ei',LastName) > 0

Select FirstName from Employees
Where DepartmentID = 3 OR DepartmentID =10 AND Year(HireDate) between 1995 and 2005

Select FirstName,LastName from Employees
Where CHARINDEX('engineer',JobTitle) = 0

Select [Name] from Towns
Where Len([Name]) = 5 OR Len([Name]) = 6
Order By [Name] Asc

Select TownId,[Name] from Towns
Where Left([Name],1) = 'M' OR Left([Name],1) = 'K' OR Left([Name],1) = 'B' Or Left([Name],1) = 'E'
Order By [Name] Asc

Select TownId,[Name] from Towns
Where [Name] Not Like 'R%' AND [Name] Not Like 'B%' AND [Name] Not Like 'D%'
Order By [Name] Asc

Create View V_EmployeesHiredAfter2000 AS
Select FirstName,LastName from Employees
Where Year(HireDate) > 2000

Select FirstName,LastName from Employees
Where Len(LastName) = 5



Select * from(
               Select EmployeeID,FirstName,LastName,Salary
              ,DENSE_RANK() OVER (Partition By Salary Order By EmployeeID) As [Rank] 
               from Employees
               Where Salary between 10000 and 50000
              ) AS [SubQuery]
Where [Rank] = 2
Order By Salary Desc



Select CountryName AS [Country Name],IsoCode AS [ISO Code] from Countries
Where CountryName LIKE '%a%a%a%'
ORDER BY IsoCode

Select p.PeakName,
       r.RiverName,
	   Lower(Concat(Substring(p.PeakName,1,Len(p.PeakName) - 1), r.RiverName))
	   As Mix
from   Peaks AS p,
       Rivers AS r
Where  RIGHT(Lower(p.PeakName),1) = LEFT(Lower(r.RiverName),1)
Order By Mix

Select Top(50) 
        [Name],
		Format([Start],'yyyy-MM-dd')As [Start] 
from Games
Where Year([Start]) IN (2011,2012)
Order By [Start],[Name]

Select Username,
       SUBSTRING(Email,CHARINDEX('@',Email)+1,Len(Email))
	   As [Email Provider]
From Users
Order By [Email Provider],Username


Select UserName,IpAddress from Users
Where IpAddress Like '___.1%.%.___'
Order by UserName

Select [Name] As Game,
Case 
	   When DatePart(Hour,[Start]) >= 0 AND DatePart(Hour,[Start]) < 12 Then 'Morning'
	   When DatePart(Hour,[Start]) >= 12 AND DatePart(Hour,[Start]) < 18 Then 'Afternoon'
	   Else 'Evening'
End
As [Part of the Day],
Case
    When Duration <= 3 Then 'Extra Short'
	When Duration > 3 AND Duration <= 6 Then 'Short'
	When Duration > 6 Then 'Long'
	When Duration IS NULL Then 'Extra Long'
End
As [Duration]
from Games
Order By Game,Duration,[Part of the Day]


Select ProductName
	  ,OrderDate
	  ,DATEADD(DAY,3,OrderDate) AS [Pay Due]
	  ,DATEADD(MONTH,1,OrderDate) AS [Deliver Due]
from Orders
