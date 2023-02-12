Create DATABASE Airport

Go


CREATE TABLE Passengers
(
Id INT PRIMARY KEY IDENTITY,
FullName VARCHAR(100) UNIQUE NOT NULL,
Email VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Pilots
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(30) UNIQUE NOT NULL,
LastName VARCHAR(30) UNIQUE NOT NULL,
Age TinyInt NOT NULL,
CHECK (Age BETWEEN 21 AND 62),
Rating FLOAT,
CHECK (Rating BETWEEN 0.0 AND 10.0)
)


CREATE TABLE AircraftTypes
(
Id INT PRIMARY KEY IDENTITY,
TypeName VARCHAR(30) UNIQUE NOT NULL
)

CREATE TABLE Aircraft
(
Id INT PRIMARY KEY IDENTITY,
Manufacturer VARCHAR(25) NOT NULL,
Model VARCHAR(30) NOT NULL,
[Year] INT NOT NULL,
FlightHours INT,
Condition CHAR(1)NOT NULL,
TypeId INT FOREIGN KEY REFERENCES AircraftTypes(Id) NOT NULL
)


CREATE TABLE PilotsAircraft
(
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PilotId INT FOREIGN KEY REFERENCES Pilots(Id) NOT NULL,
PRIMARY KEY(AircraftId,PilotId)
)


Create TABLE Airports
(
Id INT PRIMARY KEY IDENTITY,
AirportName VARCHAR(70) UNIQUE NOT NULL,
Country VARCHAR(100) UNIQUE NOT NULL
)

CREATE TABLE FlightDestinations
(
Id INT PRIMARY KEY IDENTITY,
AirportId INT FOREIGN KEY REFERENCES Airports(Id) NOT NULL,
[Start] DATETIME NOT NULL,
AircraftId INT FOREIGN KEY REFERENCES Aircraft(Id) NOT NULL,
PassengerId INT FOREIGN KEY REFERENCES Passengers(Id) NOT NULL,
TicketPrice DECIMAL(18,2) DEFAULT 15 NOT NULL
)


Insert INTO Passengers(FullName,Email)
Select Concat(FirstName,' ',LastName),
	   Concat(FirstName,LastName,'@gmail.com')
  From Pilots
 Where Id Between 5 and 15

 Update Aircraft
    Set Condition = 'A'
  WHERE (Condition = 'C' OR Condition = 'B') AND
		(FlightHours IS NULL OR FlightHours <= 100) AND
		[Year] >= 2013

Delete From Passengers
Where Len(FullName) <= 10


  Select Manufacturer,
         Model,
		 FlightHours,
		 Condition
    From Aircraft
Order By FlightHours Desc


Select p.FirstName,
       p.LastName,
	   a.Manufacturer,
	   a.Model,
	   a.FlightHours
  From Pilots As p
  JOIN PilotsAircraft As pa
  On p.Id = pa.PilotId
  JOIN Aircraft As a
  On a.Id = pa.AircraftId
 Where a.FlightHours IS NOT NULL AND a.FlightHours <= 304
Order By a.FlightHours Desc,
         p.FirstName Asc



Select TOP(20) fd.Id As DestinationId,
       fd.[Start],
	   p.FullName,
	   a.AirportName,
	   fd.TicketPrice
  From Passengers As p
  JOIN FlightDestinations As fd
  ON p.Id = fd.PassengerId
  JOIN Airports As a
  ON fd.AirportId = a.Id
  Where DAY(fd.[Start]) % 2 = 0
Order By fd.TicketPrice DESC,
         a.AirportName ASC

  Select a.Id As AircraftId,
       a.Manufacturer,
	   a.FlightHours,
	   Count(fd.Id) As FlightDestinationsCount,
	   ROUND(AVG(fd.TicketPrice),2) As AvgPrice
    From Aircraft As a
	  JOIN FlightDestinations As fd
	  ON fd.AircraftId = a.Id
Group By a.Id,a.Manufacturer,a.FlightHours
HAVING Count(fd.Id) >= 2
Order By FlightDestinationsCount Desc,
         a.Id ASC


Select p.FullName,
       Count(fd.AircraftId) As CountOfAircraft,
	   SUM(fd.TicketPrice) AS TotalPayed
  From Passengers As p
  Join FlightDestinations As fd
  On p.Id = fd.PassengerId
  Where SUBSTRING(p.FullName,2,1) = 'a'
  Group By p.FullName
  Having Count(fd.AircraftId) > 1
  Order By p.FullName




Select a.AirportName,
       fd.[Start] As DayTime,
	   fd.TicketPrice,
	   p.FullName,
	   ac.Manufacturer,
	   ac.Model
  From FlightDestinations As fd
  JOIN Airports As a
  On fd.AirportId = a.Id
  JOIN Aircraft as ac
  On ac.Id = fd.AircraftId
  JOIN Passengers As p
  On p.Id = fd.PassengerId
Where (DATEPART(HOUR,fd.[Start]) BETWEEN 6 AND 20)
      AND TicketPrice > 2500
  Order By ac.Model ASC



GO


Create FUNCTION udf_FlightDestinationsByEmail(@email VARCHAR(50))
RETURNS INT
AS
  BEGIN
        DECLARE @passengerId INT=
		(
		   Select Id
		     from Passengers
			 Where Email = @email
		)

		RETURN(
		        Select Count(*) 
				  From FlightDestinations
				  Where PassengerId = @passengerId
		      )
    END


GO



 Create PROC usp_SearchByAirportName @airportName VARCHAR(70)
 AS
   Begin
         Select a.AirportName,
		        p.FullName,
				CASE
				    When fd.TicketPrice <= 400 Then 'Low'
					When fd.TicketPrice Between 401 AND 1500 Then 'Medium'
					Else 'High'
                 End As LevelOfTickerPrice,
				ac.Manufacturer,
				ac.Condition,
				atp.TypeName
		   from Airports As a
		   JOIN FlightDestinations As fd
		   On a.Id = fd.AirportId
		   JOIN Passengers As p
		   On p.Id = fd.PassengerId
		   Join Aircraft As ac
		   On ac.Id = fd.AircraftId
		   Join AircraftTypes As atp
		   On atp.Id = ac.TypeId
		   Where a.AirportName = @airportName
		   Order By ac.Manufacturer,
		            p.FullName
     END