CREATE DATABASE Boardgames

GO

CREATE TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
StreetName NVARCHAR(100) NOT NULL,
StreetNumber INT NOT NULL,
Town VARCHAR(30) NOT NULL,
Country VARCHAR(50) NOT NULL,
ZIP INT NOT NULL
)

CREATE TABLE Publishers
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(30) UNIQUE NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL,
Website NVARCHAR(40),
Phone NVARCHAR(20)
)

CREATE TABLE PlayersRanges
(
Id INT PRIMARY KEY IDENTITY,
PlayersMin INT NOT NULL,
PlayersMax INT NOT NULL
)

CREATE TABLE Boardgames
(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(30) NOT NULL,
YearPublished INT NOT NULL,
Rating DECIMAL(16,2) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
PublisherId INT FOREIGN KEY REFERENCES Publishers(Id) NOT NULL,
PlayersRangeId INT FOREIGN KEY REFERENCES PlayersRanges(Id) NOT NULL
)

CREATE TABLE Creators
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(30) NOT NULL
)

CREATE TABLE CreatorsBoardgames
(
CreatorId INT FOREIGN KEY REFERENCES Creators(Id) NOT NULL,
BoardgameId INT FOREIGN KEY REFERENCES Boardgames(Id) NOT NULL,
PRIMARY KEY(CreatorId,BoardgameId)
)

INSERT INTO Publishers([Name],AddressId,Website,Phone)
VALUES('Agman Games',5,'www.agmangames.com','+16546135542'),
      ('Amethyst Games',7,'www.amethystgames.com','+15558889992'),
	  ('BattleBooks',13,'www.battlebooks.com','+12345678907')

INSERT INTO Boardgames([Name],YearPublished,Rating,CategoryId,PublisherId,PlayersRangeId)
VALUES ('Deep Blue',2019,5.67,1,15,7),
       ('Paris',2016,9.78,7,1,5),
	   ('Catan: Starfarers',2021,9.87,7,13,6),
	   ('Bleeding Kansas',2020,3.25,3,7,4),
	   ('One Small Step',2019,5.75,5,9,2)

UPDATE PlayersRanges
   SET PlayersMax += 1
 WHERE PlayersMin = 2 AND PlayersMax = 2

UPDATE Boardgames
   SET [Name] = [Name] + 'V2'
 WHERE YearPublished >= 2020

 Select [Name],
        Rating
   From Boardgames
Order By YearPublished Asc,
         [Name] Desc

Select b.Id,
       b.[Name],
	   b.YearPublished,
	   c.[Name] As CategoryName
  From Boardgames As b
  JOIN Categories As c
  ON c.Id = b.CategoryId
 Where c.[Name] IN ('Strategy Games','Wargames')
Order By b.YearPublished Desc


Select c.Id,
       CONCAT(c.FirstName,' ',c.LastName) As CreatorName,
	   c.Email
  From Creators As c
  LEFT JOIN CreatorsBoardgames As cb
  ON c.Id = cb.CreatorId
  WHERE cb.BoardgameId IS NULL

SELECT TOP(5)
       b.[Name],
       b.Rating,
	   c.[Name]
  From Boardgames As b
  JOIN Categories As c
  ON c.Id = b.CategoryId
  JOIN PlayersRanges As pr
  ON pr.Id = b.PlayersRangeId
WHERE (b.Rating > 7.00 AND b.[Name] LIKE '%a%') OR (b.Rating > 7.50 AND (pr.PlayersMin >=2 AND pr.PlayersMax<=5))
ORDER BY b.[Name] ASC,
         b.Rating Desc


SELECT CONCAT(c.FirstName,' ',c.LastName) As FullName,
		      c.Email,
			  MAX(b.Rating) As Rating
		  From Creators As c
		  JOIN CreatorsBoardgames As cb
		  ON cb.CreatorId = c.Id
		  JOIN Boardgames As b
		  ON b.Id = cb.BoardgameId
		 WHERE Email LIKE '%.com'
		 Group by c.FirstName,c.LastName,c.Email

SELECT c.LastName,
       CEILING(AVG(b.Rating)) As AverageRating,
	   p.[Name] As PublisherName
  From Creators As c
  JOIN CreatorsBoardgames As cb
  ON c.Id = cb.CreatorId
  JOIN Boardgames As b
  ON b.Id = cb.BoardgameId
  JOIN Publishers As p
  ON p.Id = b.PublisherId
WHERE p.[Name] = 'Stonemaier Games'
Group By c.LastName,p.[Name]
ORDER BY AVG(b.Rating) Desc


GO

CREATE FUNCTION udf_CreatorWithBoardgames(@name NVARCHAR(30))
RETURNS INT
As
  BEGIN
       RETURN(
	          Select COUNT(cb.BoardgameId)
			    From Creators As c
				LEFT JOIN CreatorsBoardgames As cb
				ON c.Id = cb.CreatorId
			   WHERE c.FirstName = @name
	         )
    END

GO

CREATE PROC usp_SearchByCategory(@category VARCHAR(50))
AS
  BEGIN
       SELECT b.[Name],
	          b.YearPublished,
			  b.Rating,
			  c.[Name] As CategoryName,
			  p.[Name] As PublisherName,
			  CAST(pr.PlayersMin As VARCHAR) + ' people' As MinPlayers,
			  CAST(pr.PlayersMax As VARCHAR) + ' people' As MaxPlayers
	     From Boardgames As b
		 JOIN Categories As c
		 ON b.CategoryId = c.Id
		 JOIN Publishers As p
		 ON p.Id = b.PublisherId
		 JOIN PlayersRanges As pr
		 ON pr.Id = b.PlayersRangeId
		 Where c.[Name] = @category
		 Order By p.[Name] Asc,
		          b.YearPublished Desc
    END

GO


Select *
  From Addresses
 Where LEFT(Town,1) = 'L'

Select *
  From Publishers
 Where AddressId = 5

Select * 
  From Boardgames
 Where PublisherId = 1


DELETE
  FROM Addresses
 Where LEFT(Town,1) = 'L'

Delete
  From Publishers
 Where AddressId = 5

Delete
  From Boardgames
 WHere PublisherId = 1

Delete
  From CreatorsBoardgames
 Where BoardgameId IN (1,16,31)


