CREATE DATABASE [Service]

GO

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) UNIQUE NOT NULL,
[Password] VARCHAR(50) NOT NULL,
[Name] VARCHAR(50),
Birthdate DATETIME,
Age INT,
CHECK(Age BETWEEN 14 AND 110),
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Departments
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Employees
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(25),
LastName VARCHAR(25),
Birthdate DATETIME,
Age INT,
CHECK(Age BETWEEN 18 AND 110),
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
)

CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL,
)

CREATE TABLE [Status]
(
Id INT PRIMARY KEY IDENTITY,
[Label] VARCHAR(20) NOT NULL
)

CREATE TABLE Reports
(
Id INT PRIMARY KEY IDENTITY,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
StatusId INT FOREIGN KEY REFERENCES [Status](Id) NOT NULL,
OpenDate DATETIME NOT NULL,
CloseDate DATETIME,
[Description] VARCHAR(200) NOT NULL,
UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
EmployeeId INT FOREIGN KEY REFERENCES Employees(Id)
)


INSERT INTO Employees(FirstName,LastName,Birthdate,DepartmentId)
VALUES('Marlo','O''Malley','1958-9-21',1),
      ('Niki','Stanaghan','1969-11-26',4),
	  ('Ayrton','Senna','1960-03-21',9),
	  ('Ronnie','Peterson','1944-02-14',9),
	  ('Giovanna','Amati','1959-07-20',5)

INSERT INTO Reports(CategoryId,StatusId,OpenDate,CloseDate,[Description],UserId,EmployeeId)
VALUES(1,1,'2017-04-13',NULL,'Stuck Road on Str.133',6,2),
      (6,3,'2015-09-05','2015-12-06','Charity trail running',3,5),
	  (14,2,'2015-09-07',NULL,'Falling bricks on Str.58',5,2),
	  (4,3,'2017-07-03','2017-07-06','Cut off streetlight on Str.11',1,1)

UPDATE Reports
   SET CloseDate = GETDATE()
 WHERE CloseDate IS NULL


DELETE FROM Reports
 WHERE [StatusId] = 4


  Select [Description],
         FORMAT(OpenDate,'dd-MM-yyyy')
    From Reports
   Where EmployeeId IS NULL 
Order By OpenDate Asc,
         [Description] Asc


Select r.[Description],
       c.[Name]
  From Reports As r
  Left Join Categories As c
  On r.CategoryId = c.Id
Order By r.[Description] Asc,
         c.[Name] Asc


Select TOP(5) c.[Name],
       COUNT(r.Id) As ReportsNumber
  from Categories As c
  JOIN Reports As r
  On c.Id = r.CategoryId
Group By c.[Name]
Order By  ReportsNumber Desc,
          c.[Name] Asc


Select u.Username,
       c.[Name] As CategoryName
  From Users As u
  Join Reports As r
  On u.Id = r.UserId
  Join Categories As c
  On r.CategoryId = c.Id
Where (MONTH(OpenDate) = MONTH(Birthdate)) AND (DAY(OpenDate) = DAY(Birthdate))
Order By u.Username Asc,
         c.[Name] Asc

Select CONCAT(e.FirstName,' ',e.LastName) As FullName,
       COUNT(DISTINCT UserID) As UsersCount
  From Employees As e
  LEFT JOIN Reports As r
  ON e.Id = r.EmployeeId
  Group By e.FirstName,e.LastName
  Order By UsersCount Desc,
           FullName Asc

Select CASE
           WHEN CONCAT(e.FirstName,' ',e.LastName) = '' THEN 'None'
		   ELSE CONCAT(e.FirstName,' ',e.LastName)
		END As Employee,
       CASE
	       WHEN d.[Name] IS NULL THEN 'None'
		   Else d.[Name]
		END As Department,
	   c.[Name] As Category,
	   r.[Description],
	   FORMAT(r.OpenDate,'dd.MM.yyyy') As OpenDate,
	   s.[Label],
	   u.[Name]
  from Reports As r
  LEFT JOIN Employees As e
  ON e.Id = r.EmployeeId
  LEFT JOIN Departments As d
  On d.Id = e.DepartmentId
  LEFT JOIN Categories As c
  On c.Id = r.CategoryId
  LEFT JOIN [Status] As s
  On s.Id = r.StatusId
  LEFT JOIN Users As u
  On r.UserId = u.Id
Order By e.FirstName Desc,
         e.LastName Desc,
		 d.[Name] Asc,
		 c.[Name] Asc,
		 r.[Description] Asc,
		 r.OpenDate Asc,
		 s.[Label] Asc,
		 u.[Name] Asc

GO

CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME)
RETURNS INT
AS
  BEGIN
        IF @StartDate IS NULL 
		RETURN 0

		If @EndDate IS NULL
		RETURN 0

		RETURN DATEDIFF(HOUR,@StartDate,@EndDate)
    END

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

GO

CREATE PROC usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
  BEGIN
       DECLARE @EmployeeDepartmentId INT = (
	                                         Select DepartmentId
											   From Employees
                                              WHERE Id = @EmployeeId
	                                       )

       DECLARE @CategoryDepartmentId INT = (
	                                         Select DepartmentId
											   from Categories As c
											   JOIN Reports As r
											   On r.CategoryId = c.Id
											  WHERE r.Id = @ReportId
	                                       )

       If @CategoryDepartmentId = @EmployeeDepartmentId
	   UPDATE Reports
	      SET EmployeeId = @EmployeeId
        WHERE Id = @ReportId
	   ELSE
	   THROW 50001,'Employee doesn''t belong to the appropriate department!',1
    END
