Create DATABASE Zoo

Go


Create Table Owners
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50)
)


Create TABLE AnimalTypes
(
Id INT PRIMARY KEY IDENTITY,
AnimalType VARCHAR(30) NOT NULL
)

Create TABLE Cages
(
Id INT PRIMARY KEY IDENTITY,
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)


Create TABLE Animals
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) NOT NULL,
BirthDate DATE NOT NULL,
OwnerId INT FOREIGN KEY REFERENCES Owners(Id),
AnimalTypeId INT FOREIGN KEY REFERENCES AnimalTypes(Id) NOT NULL
)


Create TABLE AnimalsCages
(
CageId INT FOREIGN KEY REFERENCES Cages(Id) NOT NULL,
AnimalId INT FOREIGN KEY REFERENCES Animals(Id) NOT NULL,
PRIMARY KEY(CageId,AnimalId)
)

Create TABLE VolunteersDepartments
(
Id INT PRIMARY KEY IDENTITY,
DepartmentName VARCHAR(30) NOT NULL
)


Create TABLE Volunteers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
PhoneNumber VARCHAR(15) NOT NULL,
[Address] VARCHAR(50),
AnimalId INT FOREIGN KEY REFERENCES Animals(Id),
DepartmentId INT FOREIGN KEY REFERENCES VolunteersDepartments(Id) NOT NULL
)



INSERT INTO Animals([Name],BirthDate,OwnerId,AnimalTypeId)
Values('Giraffe','2018-09-21',21,1),
      ('Harpy Eagle','2015-04-17',15,3),
	  ('Hamadryas Baboon','2017-11-02',NULL,1),
	  ('Tuatara','2021-06-30',2,4)


INSERT INTO Volunteers([Name],PhoneNumber,[Address],AnimalId,DepartmentId)
VALUES('Anita Kostova','0896365412','Sofia, 5 Rosa str.',15,1),
      ('Dimitur Stoev','0877564223',NULL,42,4),
	  ('Kalina Evtimova','0896321112','Silistra, 21 Breza str.',9,7),
	  ('Stoyan Tomov','0898564100','Montana, 1 Bor str.',18,8),
	  ('Boryana Mileva','0888112233',NULL,31,5)



SELECT * FROM Animals
WHERE OwnerId = 4


SELECT * FROM Owners
WHERE [Name] = 'Kaloqn Stoqnov'


UPDATE Animals
   SET OwnerId = 4
 WHERE OwnerId IS NULL



 Select * from VolunteersDepartments


 DELETE FROM Volunteers
 Where DepartmentId = 2

 Delete FROM VolunteersDepartments
 Where Id = 2

 GO

 CREATE FUNCTION udf_GetVolunteersCountFromADepartment (@VolunteersDepartment VARCHAR(30))
 RETURNS INT
 AS
   BEGIN
    
             DECLARE @DepartmentId INT = (
			                               Select Id from VolunteersDepartments
									       Where DepartmentName = @VolunteersDepartment
			                             )

		   RETURN(
				 Select Count(*) AS VolunteersInDepartment
				   FROM Volunteers
				   Where DepartmentId = @DepartmentId
				 )
     END

GO

SELECT dbo.udf_GetVolunteersCountFromADepartment ('Education program assistant')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Guest engagement')
SELECT dbo.udf_GetVolunteersCountFromADepartment ('Zoo events')

GO

Create Proc usp_AnimalsWithOwnersOrNot(@AnimalName VARCHAR(30))
AS
  BEGIN
        Select a.[Name],
		       Case
			       When o.[Name] IS NULL THEN 'For adoption'
				   Else o.[Name]
				End As OwnersName
		  from Animals AS a
		  Left Join Owners as o
		  On a.OwnerId = o.Id
         WHERE a.[Name] = @AnimalName
    END

GO

EXEC usp_AnimalsWithOwnersOrNot 'Pumpkinseed Sunfish'
EXEC usp_AnimalsWithOwnersOrNot 'Hippo'
EXEC usp_AnimalsWithOwnersOrNot 'Brown bear'


Select [Name],PhoneNumber,[Address],AnimalId,DepartmentId
  From Volunteers
  Order By [Name] Asc,
           AnimalId Asc,
		   DepartmentId Asc

Select a.[Name],
       ant.AnimalType,
	   FORMAT(a.BirthDate,'dd.MM.yyyy') AS BirthDate
  from Animals As a
  Left Join AnimalTypes As ant
  On a.AnimalTypeId = ant.Id
  Order By a.[Name] Asc


Select Top (5) o.[Name] As [Owner],
       COUNT(a.OwnerId) As CountOfAnimals
  From Owners As o
  Left Join Animals As a
  On a.OwnerId = o.Id
  Group By a.OwnerId,o.[Name]
  Order By CountOfAnimals DESC



   Select CONCAT(o.[Name],'-',a.[Name]) As OwnersAnimals,
          o.PhoneNumber,
		  ac.CageId
     From Owners As o
Inner Join Animals AS a
     ON o.Id=a.OwnerId
Inner Join AnimalsCages As ac
     ON ac.AnimalId = a.Id
Inner Join AnimalTypes As ant
     ON a.AnimalTypeId = ant.Id
	 Where ant.AnimalType = 'mammals'
	 Order By o.[Name] Asc,
	          a.[Name] Desc



Select v.[Name],
       v.PhoneNumber,
	   SUBSTRING(v.[Address],CHARINDEX(',',v.[Address])+1,LEN(v.[Address])) As [Address]
  From Volunteers As v
  Join VolunteersDepartments As vd
  On v.DepartmentId = vd.Id
  Where v.[Address] Like '%Sofia%' AND vd.DepartmentName = 'Education program assistant'
  Order By v.[Name] ASC


  Select a.[Name],
         YEAR(a.BirthDate) As BirthDate,
		 ant.AnimalType
    From Animals As a
	Left Join AnimalTypes As ant
	On a.AnimalTypeId = ant.Id
	Where OwnerId IS NULL AND 
	AnimalTypeId <> 3 AND 
	DATEDIFF(Year,a.BirthDate,'01/01/2022') < 5
    Order By a.[Name]
