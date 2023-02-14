Create Database CigarShop

GO

Create Table Sizes
(
Id INT PRIMARY KEY IDENTITY,
[Length] INT NOT NULL,
CHECK([Length] BETWEEN 10 AND 25),
RingRange DECIMAL(18,2) NOT NULL,
CHECK(RingRange BETWEEN 1.5 AND 7.5)
)

Create Table Tastes
(
Id INT PRIMARY KEY IDENTITY,
TasteType VARCHAR(20) NOT NULL,
TasteStrength VARCHAR(15) NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)


CREATE TABLE Brands
(
Id INT PRIMARY KEY IDENTITY,
BrandName VARCHAR(30) NOT NULL UNIQUE,
BrandDescription VARCHAR(MAX)
)


CREATE TABLE Cigars
(
Id INT PRIMARY KEY IDENTITY,
CigarName VARCHAR(80) NOT NULL,
BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
PriceForSingleCigar MONEY NOT NULL,
ImageURL NVARCHAR(100) NOT NULL
)

CREATE TABLE Addresses
(
Id INT PRIMARY KEY IDENTITY,
Town VARCHAR(30) NOT NULL,
Country NVARCHAR(30) NOT NULL,
Streat NVARCHAR(100) NOT NULL,
ZIP VARCHAR(20) NOT NULL
)


CREATE TABLE Clients
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
Email NVARCHAR(50) NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
)

CREATE TABLE ClientsCigars
(
ClientId INT FOREIGN KEY REFERENCES Clients(Id),
CigarId INT FOREIGN KEY REFERENCES Cigars(Id),
PRIMARY KEY(ClientId,CigarId)
)


INSERT INTO Addresses(Town,Country,Streat,ZIP)
VALUES('Sofia','Bulgaria','18 Bul. Vasil levski','1000'),
      ('Athens','Greece','4342 McDonald Avenue','10435'),
	  ('Zagreb','Croatia','4333 Lauren Drive','10000')


INSERT INTO Cigars(CigarName,BrandId,TastId,SizeId,PriceForSingleCigar,ImageURL)
VALUES('COHIBA ROBUSTO',9,1,5,15.50,'cohiba-robusto-stick_18.jpg'),
      ('COHIBA SIGLO I',9,1,10,410.00,'cohiba-siglo-i-stick_12.jpg'),
	  ('HOYO DE MONTERREY LE HOYO DU MAIRE',14,5,11,7.50,'hoyo-du-maire-stick_17.jpg'),
	  ('HOYO DE MONTERREY LE HOYO DE SAN JUAN',14,4,15,32.00,'hoyo-de-san-juan-stick_20.jpg'),
	  ('TRINIDAD COLONIALES',2,3,8,85.21,'trinidad-coloniales-stick_30.jpg')


UPDATE Cigars
   SET PriceForSingleCigar += PriceForSingleCigar * 0.20
 WHERE TastId = 1

UPDATE Brands
   SET BrandDescription = 'New description'
 WHERE BrandDescription IS NULL


Select *
  From Addresses
 WHERE LEFT(Country,1) = 'C'

Delete FROM Clients
 Where AddressId IN(7,8,10)

Delete FROM Addresses
 WHERE LEFT(Country,1) = 'C'



  Select CigarName,
         PriceForSingleCigar,
   	     ImageURL
    From Cigars
Order By PriceForSingleCigar Asc,
         CigarName Desc


Select c.Id,
       c.CigarName,
	   c.PriceForSingleCigar,
	   t.TasteType,
	   t.TasteStrength
  From Cigars As c
  Join Tastes As t
  On c.TastId = t.Id
 Where t.TasteType IN ('Earthy','Woody')
Order By c.PriceForSingleCigar Desc



   Select c.Id,
          CONCAT(c.FirstName,' ',c.LastName) As ClientName,
		  c.Email
     From Clients As c
LEFT JOIN ClientsCigars As cc
       On c.Id = cc.ClientId
    Where cc.CigarId IS NULL
 Order By ClientName Asc


Select TOP(5) c.CigarName,
       c.PriceForSingleCigar,
	   c.ImageURL
  From Cigars As c
  Join Sizes As s
  On c.SizeId = s.Id
 Where s.[Length] >= 12 AND 
       (c.CigarName LIKE '%ci%' OR c.PriceForSingleCigar > 50)
       AND s.RingRange > 2.55
Order By c.CigarName Asc,
         c.PriceForSingleCigar Desc


Select CONCAT(c.FirstName,' ',c.LastName) As FullName,
       a.Country,
	   a.ZIP,
	   '$' + CAST(MAX(cig.PriceForSingleCigar) As VARCHAR) As CigarPrice
  From Clients As c
  Join Addresses As a
  On c.AddressId = a.Id
  Join ClientsCigars As cc
  On c.Id = cc.ClientId
  Join Cigars As cig
  On cc.CigarId = cig.Id
 Where a.ZIP NOT LIKE '%[^0-9]%'
 Group By c.FirstName,c.LastName,a.Country,a.ZIP
 Order By FullName Asc


Select c.LastName,
       AVG(s.[Length]) As CigarLength,
	   CEILING(AVG(s.RingRange)) As CigarRingRange
  From Clients As c
  INNER JOIN ClientsCigars As cc
  ON c.Id = cc.ClientId
  INNER JOIN Cigars As cig
  ON cig.Id = cc.CigarId
  INNER JOIN Sizes As s
  ON s.Id = cig.SizeId
  Group By c.LastName
  Order By CigarLength Desc


Go

Create FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT
AS
 BEGIN
       RETURN
	         (
			   Select COUNT(CigarId)
			     from Clients As c
				 LEFT JOIN ClientsCigars As cc
				 ON c.Id = cc.ClientId
				 Where FirstName = @name
			 )
   END

Go

Create PROC usp_SearchByTaste(@taste VARCHAR(20))
As
  BEGIN
       Select c.CigarName,
	          '$'+CAST(c.PriceForSingleCigar As VARCHAR) As Price,
			  t.TasteType,
			  b.BrandName,
			  CAST(s.[Length] As VARCHAR)+' cm' As CigarLength,
			  CAST(s.RingRange As VARCHAR)+' cm' As CigarRingRange
	     from Cigars As c
         JOIN Tastes As t
		 On c.TastId = t.Id
		 JOIN Sizes As s
		 On s.Id = c.SizeId
		 JOIN Brands As b
		 ON b.Id = c.BrandId
		 Where TasteType = @taste
		 Order By s.[Length] Asc,
		          s.RingRange Desc
    END