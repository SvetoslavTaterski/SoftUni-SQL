CREATE DATABASE Bitbucket

GO

CREATE TABLE Users
(
Id INT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(30) NOT NULL,
Email VARCHAR(50) NOT NULL
)

CREATE TABLE Repositories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
PRIMARY KEY(RepositoryId,ContributorId)
)

CREATE TABLE Issues
(
Id INT PRIMARY KEY IDENTITY,
Title VARCHAR(255) NOT NULL,
IssueStatus VARCHAR(6) NOT NULL,
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Commits
(
Id INT PRIMARY KEY IDENTITY,
[Message] VARCHAR(255) NOT NULL,
IssueId INT FOREIGN KEY REFERENCES Issues(Id),
RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
Size DECIMAL(16,2) NOT NULL,
ParentId INT FOREIGN KEY REFERENCES Files(Id),
CommitId INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL,
)


INSERT INTO Files([Name],Size,ParentId,CommitId)
VALUES('Trade.idk',2598.0,1,1),
      ('menu.net',9238.31,2,2),
	  ('Administrate.soshy',1246.93,3,3),
	  ('Controller.php',7353.15,4,4),
	  ('Find.java',9957.86,5,5),
	  ('Controller.json',14034.87,3,6),
	  ('Operate.xix',7662.92,7,7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId)
VALUES ('Critical Problem with HomeController.cs file','open',1,4),
       ('Typo fix in Judge.html','open',4,3),
	   ('Implement documentation for UsersService.cs','closed',8,2),
	   ('Unreachable code in Index.cs','open',9,8)

UPDATE Issues
   SET IssueStatus = 'closed'
 WHERE AssigneeId = 6



DELETE FROM RepositoriesContributors
WHERE RepositoryId = 3

DELETE FROM Issues
WHERE RepositoryId = 3
 

Select Id,
       [Message],
	   RepositoryId,
	   ContributorId
  From Commits
Order By Id Asc,
         [Message] Asc,
		 RepositoryId Asc,
		 ContributorId Asc

Select Id,
       [Name],
       Size
  From Files
 Where Size > 1000
       AND [Name] LIKE '%html%'
Order By Size Desc,
         Id Asc,
		 [Name] Asc


Select i.Id,
       CONCAT(u.Username,' : ',i.Title) As IssueAssignee
  From Issues As i
  JOIN Users As u
  ON i.AssigneeId = u.Id
Order By i.Id Desc,
         IssueAssignee Asc

Select f.Id,
       f.[Name],
	   CONCAT(f.Size,'KB') As Size
  From Files As f
  Left JOIN Files As f2
  ON f.Id = f2.ParentId
  Where f2.ParentId IS NULL
  ORDER BY f.Id Asc,
           f.[Name] Asc,
		   f.Size Desc

Select TOP(5)
       r.Id,
       r.[Name],
	   Count(c.Id) As Commits
  From Repositories As r
  JOIN Commits As c
  ON r.Id = c.RepositoryId
  JOIN RepositoriesContributors As rc
  ON rc.RepositoryId = r.Id
Group By r.Id,r.[Name]
Order By Commits Desc,
         r.Id Asc,
		 r.[Name] Asc 
  
Select u.Username,
       AVG(f.Size) As Size
  From Users As u
  JOIN Commits As c
  On u.Id = c.ContributorId
  JOIN Files As f
  On f.CommitId = c.Id
Group By u.Username
Order By Size Desc,
         u.Username Asc

Go

Create FUNCTION udf_AllUserCommits(@username VARCHAR(30))
RETURNS INT
AS
  BEGIN
       Return(
			 Select COUNT(c.Id) 
			 From Users As u
			 LEFT JOIN Commits As c
			 ON u.Id = c.ContributorId
			 WHERE u.Username = @username
			 )
    END

GO

CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
  BEGIN
       SELECT Id,
	          [Name],
	          CONCAT(Size,'KB') As Size
	     From Files
       Where [Name] LIKE '%' + @fileExtension
    END