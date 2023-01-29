Select TOP(5) EmployeeID,JobTitle,a.AddressID,AddressText
from Employees As e
Join Addresses As a On e.AddressID = a.AddressID
Order By AddressID ASC

Select Top(50) e.FirstName,e.LastName,t.[Name],a.AddressText 
from Employees As e
Join Addresses As a On e.AddressID = a.AddressID
Join Towns As t On t.TownID = a.TownID
Order By FirstName Asc,
         LastName Asc

Select e.EmployeeID,e.FirstName,e.LastName,d.[Name] 
from Employees As e
Join Departments As d On d.DepartmentID = e.DepartmentID
Where d.DepartmentID = 3
Order By EmployeeID Asc


Select Top(5) e.EmployeeID,e.FirstName,e.Salary,d.[Name]
from Employees As e
Join Departments As d On d.DepartmentID = e.DepartmentID
Where e.Salary > 15000
Order By d.DepartmentID Asc

Select Top(3) e.EmployeeID,e.FirstName
from Employees As e
Left Join EmployeesProjects As ep On e.EmployeeID = ep.EmployeeID
Where ep.ProjectID Is NULL
Order By e.EmployeeID Asc


Select e.FirstName,e.LastName,e.HireDate,d.[Name] 
from Employees As e
Join Departments As d On e.DepartmentID = d.DepartmentID
Where e.HireDate > '1.1.1999' AND d.[Name] IN ('Sales','Finance')
Order By e.HireDate Asc

Select Top(5) e.EmployeeID,e.FirstName,p.[Name] As ProjectName  
from Employees As e
Join EmployeesProjects As ep On e.EmployeeID = ep.EmployeeID
Join Projects As p On p.ProjectID = ep.ProjectID
Where p.StartDate > '08.13.2002' And p.EndDate IS NULL
Order By EmployeeID Asc


Select e.EmployeeID,e.FirstName,
Case
    When p.StartDate >= '01/01/2005' Then NULL
	Else p.[Name]
End As ProjectName
from Employees As e
Join EmployeesProjects As ep On e.EmployeeID = ep.EmployeeID
Left Join Projects As p On p.ProjectID = ep.ProjectID
Where e.EmployeeID = 24

Select e.EmployeeID
      ,e.FirstName
	  ,e.ManagerID
	  ,m.FirstName As ManagerName
From Employees As e
Join Employees AS m 
     On e.ManagerID = m.EmployeeID
Where e.ManagerID IN (3,7)
Order By e.EmployeeID Asc

Select Top(50) e.EmployeeID,e.FirstName + ' ' + e.LastName As EmployeeName,m.FirstName + ' ' + m.LastName As ManagerName,d.[Name] As DepartmentName
From Employees As e
Join Employees As m
On e.ManagerID = m.EmployeeID
Join Departments As d
On d.DepartmentID = e.DepartmentID
Order By EmployeeID

Select Top(1)
Avg(Salary) As MinAverageSalary
from Employees
Group By DepartmentID
Order By MinAverageSalary Asc

Select mc.CountryCode,m.MountainRange,p.PeakName,p.Elevation
from MountainsCountries As mc
Join Mountains As m On mc.MountainId = m.Id
Join Peaks As p On p.MountainId = m.Id
Where mc.CountryCode = 'BG' AND p.Elevation > 2835
Order By p.Elevation Desc

Select mc.CountryCode,
Count(m.MountainRange) As MountainRanges
from MountainsCountries As mc
Join Mountains As m On mc.MountainId = m.Id
Join Countries As c On c.CountryCode = mc.CountryCode
Where c.CountryName In ('Bulgaria','United States','Russia')
Group By mc.CountryCode


Select Top(5) c.CountryName,r.RiverName
from Countries As c
Left Join CountriesRivers As cr On c.CountryCode = cr.CountryCode
LEft Join Rivers As r On r.Id = cr.RiverId
Where c.ContinentCode = 'AF'
Order By c.CountryName Asc

Select ContinentCode,CurrencyCode,CurrencyUsage
FROM (
            SELECT *,
                   DENSE_RANK() OVER (PARTITION BY [ContinentCode] ORDER BY [CurrencyUsage] DESC)
                AS [CurrencyRank]
              FROM (
                        SELECT [ContinentCode],
                               [CurrencyCode],
                               COUNT(*)
                            AS [CurrencyUsage]
                          FROM [Countries]
                      GROUP BY [ContinentCode], [CurrencyCode]
                        HAVING COUNT(*) > 1
                   )
                AS [CurrencyUsageSubquery]
       )
    AS [CurrencyRankingSubquery]
 WHERE [CurrencyRank] = 1


 Select Count(*) 
 from Countries As c
 Left Join MountainsCountries As mc On c.CountryCode = mc.CountryCode
 Where mc.MountainId IS NULL


Select 
Top(5) c.CountryName,
MAX(p.Elevation) AS [HighestPeakElevation],
Max(r.[Length])  AS [LongestRiverLength]
from Countries As c
Left Join CountriesRivers As cr 
On cr.CountryCode = c.CountryCode
LEft Join Rivers As r 
On r.Id = cr.RiverId
Left Join MountainsCountries As mc 
On c.CountryCode = mc.CountryCode
LEft Join Mountains As m 
On m.Id = mc.MountainId
LEft Join Peaks As p 
On p.MountainId = m.Id
Group By c.CountryName
Order By [HighestPeakElevation] Desc,
          [LongestRiverLength] Desc,
		  c.CountryName Asc



SELECT 
 TOP (5) [CountryName]
      AS [Country],
         ISNULL([PeakName], '(no highest peak)')
      AS [Highest Peak Name],
         ISNULL([Elevation], 0)
      AS [Highest Peak Elevation],
         ISNULL([MountainRange], '(no mountain)')
      AS [Mountain]
    FROM (
               SELECT [c].[CountryName],
                      [p].[PeakName],
                      [p].[Elevation],
                      [m].[MountainRange],
                      DENSE_RANK() OVER(PARTITION BY [c].[CountryName] ORDER BY [p].[Elevation] DESC)
                   AS [PeakRank]
                 FROM [Countries]
                   AS [c]
            LEFT JOIN [MountainsCountries]
                   AS [mc]
                   ON [mc].[CountryCode] = [c].[CountryCode]
            LEFT JOIN [Mountains]
                   AS [m]
                   ON [mc].[MountainId] = [m].[Id]
            LEFT JOIN [Peaks]
                   AS [p]
                   ON [p].[MountainId] = [m].[Id]
         ) 
      AS [PeakRankingSubquery]
   WHERE [PeakRank] = 1
ORDER BY [Country],
         [Highest Peak Name]