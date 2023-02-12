Create DATABASE NationalTouristSitesOfBulgaria

GO

Use NationalTouristSitesOfBulgaria

GO

Create TABLE Categories
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
)


CREATE TABLE Locations
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Municipality VARCHAR(50),
Province VARCHAR(50)
)


CREATE TABLE Sites
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(100) NOT NULL,
LocationId INT FOREIGN KEY REFERENCES Locations(Id) NOT NULL,
CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
Establishment VARCHAR(15)
)


CREATE TABLE Tourists
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL,
Age INT NOT NULL,
CHECK (Age BETWEEN 0 AND 120),
PhoneNumber VARCHAR(20) NOT NULL,
Nationality VARCHAR(30) NOT NULL,
Reward VARCHAR(20)
)


CREATE TABLE SitesTourists
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
SiteId INT FOREIGN KEY REFERENCES Sites(Id) NOT NULL
PRIMARY KEY(TouristId,SiteId)
)


CREATE TABLE BonusPrizes
(
Id INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) NOT NULL
)


CREATE TABLE TouristsBonusPrizes
(
TouristId INT FOREIGN KEY REFERENCES Tourists(Id) NOT NULL,
BonusPrizeId INT FOREIGN KEY REFERENCES BonusPrizes(Id) NOT NULL,
PRIMARY KEY(TouristId,BonusPrizeId)
)


Insert Into Tourists([Name],Age,PhoneNumber,Nationality,Reward)
Values('Borislava Kazakova',52,'+359896354244','Bulgaria',NULL),
      ('Peter Bosh',48,'+447911844141','UK',NULL),
	  ('Martin Smith',29,'+353863818592','Ireland','Bronze badge'),
	  ('Svilen Dobrev',49,'+359986584786','Bulgaria','Silver badge'),
	  ('Kremena Popova',38,'+359893298604','Bulgaria',NULL)

Insert INTO Sites([Name],LocationId,CategoryId,Establishment)
VALUES('Ustra fortress',90,7,'X'),
      ('Karlanovo Pyramids',65,7,NULL),
	  ('The Tomb of Tsar Sevt',63,8,'V BC'),
	  ('Sinite Kamani Natural Park',17,1,NULL),
	  ('St. Petka of Bulgaria – Rupite',92,6,'1994')


UPDATE Sites
   SET Establishment = '(not defined)'
 WHERE Establishment IS NULL

 Delete
   From TouristsBonusPrizes
  Where BonusPrizeId = 5


 Delete 
   FROM BonusPrizes
  Where [Name] = 'Sleeping bag'




  Select [Name],
         Age,
	     PhoneNumber,
	     Nationality
    From Tourists
Order By Nationality Asc,
         Age Desc,
		 [Name] Asc



Select s.[Name] As [Site],
       l.[Name] As [Location],
	   s.Establishment,
	   c.[Name] As Category
  From Sites As s
  LEFT JOIN Categories As c
  On s.CategoryId = c.Id
  LEFT JOIN Locations As l
  On l.Id = s.LocationId
Order By c.[Name] Desc,
         l.[Name] Asc,
		 s.[Name] Asc



   Select l.Province,
          l.Municipality,
		  l.[Name] As [Location],
		  Count(s.Id) As CountOfSites
     From Locations As l
INNER JOIN Sites As s
       ON l.Id = s.LocationId
    Where Province = 'Sofia'
 Group By l.Province,l.Municipality,l.[Name]
 Order By CountOfSites Desc,
          l.[Name] Asc


  Select s.[Name] As [Site],
         l.[Name] As [Location],
    	 l.Municipality,
	     l.Province,
	     s.Establishment
    From Sites As s
    Join Locations As l
      On s.LocationId = l.Id
   Where LEFT(l.[Name],1) NOT IN('B','M','D') 
         AND (s.Establishment LIKE '%BC')
Order By s.[Name] Asc


Select t.[Name],
       Age,
	   PhoneNumber,
	   Nationality,
	   Case
	       When bp.[Name] IS NULL THEN '(no bonus prize)'
		   Else bp.[Name]
		End As Rewards
  from Tourists As t
  Left Join TouristsBonusPrizes As tbp
  On t.Id = tbp.TouristId
  Left Join BonusPrizes As bp
  On bp.Id = tbp.BonusPrizeId
Order by t.[Name] Asc


   Select SUBSTRING(t.[Name],CHARINDEX(' ',t.[Name]),LEN(t.[Name])) As LastName,
          Nationality,
	      Age,
	      PhoneNumber
     From Tourists As t
Left Join SitesTourists As st
       On t.Id = st.TouristId
Left Join Sites As s
       On s.Id = st.SiteId
Left Join Categories As c
       On c.Id = s.CategoryId
 Group By t.[Name],t.Nationality,t.Age,t.PhoneNumber,c.Id
 Having c.Id = 8
 Order By LastName Asc


 Go

 Create FUNCTION udf_GetTouristsCountOnATouristSite (@Site VARCHAR(100))
 Returns INT
 As
   Begin
    Declare @SiteId INT = (
	                        Select Id
							  from Sites
                             Where [Name] = @Site
	                      )
   Return
   (
     Select COUNT(*)
	   from SitesTourists
      Where SiteId = @SiteId
   )
     END    
		
GO

SELECT dbo.udf_GetTouristsCountOnATouristSite ('Regional History Museum – Vratsa')	
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Samuil’s Fortress')
SELECT dbo.udf_GetTouristsCountOnATouristSite ('Gorge of Erma River')

Go

Create Proc usp_AnnualRewardLottery(@TouristName VARCHAR(50))
AS
  Begin
       Select [Name],
	          Case
			      When Count(*) >= 100 Then 'Gold badge'
				  When Count(*) >= 50 Then 'Silver badge'
				  When Count(*) >= 25 Then 'Bronze badge'
               End As Reward
	     From Tourists As t
		 Join SitesTourists As st
		 On t.Id = st.TouristId
		 Where [Name] = @TouristName
		 Group By st.TouristId,t.[Name]
    End