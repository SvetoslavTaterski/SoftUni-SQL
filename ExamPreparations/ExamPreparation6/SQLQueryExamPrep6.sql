CREATE DATABASE WMS

GO

CREATE TABLE Clients
(
ClientId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Phone VARCHAR(12) NOT NULL,
CHECK(LEN(Phone) = 12)
)

CREATE TABLE Mechanics
(
MechanicId INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
ModelId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Jobs
(
JobId INT PRIMARY KEY IDENTITY,
ModelId INT FOREIGN KEY REFERENCES Models(ModelId) NOT NULL,
[Status] VARCHAR(11) DEFAULT 'Pending' NOT NULL,
CHECK ([Status] IN ('Pending','In Progress','Finished')),
ClientId INT FOREIGN KEY REFERENCES Clients(ClientId) NOT NULL,
MechanicId INT FOREIGN KEY REFERENCES Mechanics(MechanicId),
IssueDate DATE NOT NULL,
FinishDate DATE
)

CREATE TABLE Orders
(
OrderId INT PRIMARY KEY IDENTITY,
JobId INT FOREIGN KEY REFERENCES Jobs(JobId) NOT NULL,
IssueDate DATE,
Delivered BIT DEFAULT 0 NOT NULL
)

CREATE TABLE Vendors
(
VendorId INT PRIMARY KEY IDENTITY,
[Name] VARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Parts
(
PartId INT PRIMARY KEY IDENTITY,
SerialNumber VARCHAR(50) UNIQUE NOT NULL,
[Description] VARCHAR(255),
Price DECIMAL(6,2) NOT NULL,
CHECK(Price > 0),
VendorId INT FOREIGN KEY REFERENCES Vendors(VendorId) NOT NULL,
StockQty INT NOT NULL DEFAULT 0,
CHECK (StockQty >= 0),
)


CREATE TABLE OrderParts
(
OrderId INT FOREIGN KEY REFERENCES Orders(OrderId),
PartId INT FOREIGN KEY REFERENCES Parts(PartId),
Quantity INT DEFAULT 1 NOT NULL,
CHECK (Quantity > 0),
PRIMARY KEY(OrderId,PartId)
)

CREATE TABLE PartsNeeded
(
JobId INT FOREIGN KEY REFERENCES Jobs(JobId),
PartId INT FOREIGN KEY REFERENCES Parts(PartId),
Quantity INT DEFAULT 1 NOT NULL,
CHECK (Quantity > 0),
PRIMARY KEY(JobId,PartId)
)


INSERT INTO Clients(FirstName,LastName,Phone)
VALUES('Teri','Ennaco','570-889-5187'),
      ('Merlyn','Lawler','201-588-7810'),
	  ('Georgene','Montezuma','925-615-5185'),
	  ('Jettie','Mconnell','908-802-3564'),
	  ('Lemuel','Latzke','631-748-6479'),
	  ('Melodie','Knipp','805-690-1682'),
	  ('Candida','Corbley','908-275-8357')

INSERT INTO Parts(SerialNumber,[Description],Price,VendorId)
Values('WP8182119','Door Boot Seal',117.86,2),
      ('W10780048','Suspension Rod',42.81,1),
	  ('W10841140','Silicone Adhesive',6.77,4),
	  ('WPY055980','High Temperature Adhesive',13.94,3)


UPDATE Jobs
   Set MechanicId = 3,
       [Status] = 'In Progress'
 WHERE [Status] = 'Pending'

 DELETE FROM OrderParts
  WHERE OrderId = 19

 DELETE FROM Orders
  WHERE OrderId = 19


Select CONCAT(m.FirstName,' ',m.LastName) As Mechanic,
       j.[Status],
	   j.IssueDate
  From Mechanics As m
  Join Jobs As j
  On j.MechanicId = m.MechanicId
Order By m.MechanicId Asc,
         j.IssueDate Asc,
		 j.JobId Asc


Select CONCAT(c.FirstName,' ',c.LastName) As Client,
       DATEDIFF(Day,j.IssueDate,'2017-04-24') As [Days Going],
	   j.[Status]
  From Clients As c
  Join Jobs As j
  On j.ClientId = c.ClientId
 WHERE j.[Status] <> 'Finished'
Order By [Days Going] Desc,
         c.ClientId Asc

Select CONCAT(m.FirstName,' ',m.LastName) As Mechanic,
       AVG(DATEDIFF(DAY,j.IssueDate,j.FinishDate)) As [Average Days]
  From Mechanics As m
  Join Jobs As j
  On j.MechanicId = m.MechanicId
Group By m.FirstName,m.LastName,m.MechanicId
ORDER BY m.MechanicId


Select CONCAT(FirstName,' ',LastName) AS Available
  From Mechanics
 Where MechanicId NOT IN(
                          Select MechanicId
						    from Jobs
                           Where [Status] = 'In Progress'
                        )
Order By MechanicId Asc


Select j.JobId,
       ISNULL(SUM(p.Price * op.Quantity),0) As Total
  From Jobs As j
LEFT JOIN Orders As o
  ON o.JobId = j.JobId
LEFT JOIN OrderParts As op
  ON op.OrderId = o.OrderId
LEFT JOIN Parts As p
  ON p.PartId = op.PartId
 Where j.[Status] = 'Finished'
Group By j.JobId
Order By Total Desc,
         j.JobId Asc


Select p.PartId,
       p.[Description],
	   SUM(pn.Quantity) As Requiered,
	   SUM(p.StockQty) As [In Stock],
	   ISNULL(SUM(op.Quantity),0) As Ordered
  From Parts As p
  LEFT JOIN PartsNeeded As pn
  ON p.PartId = pn.PartId
  LEFT JOIN Jobs As j
  On pn.JobId = j.JobId
  LEFT JOIN Orders As o
  ON j.JobId = o.JobId
  LEFT JOIN OrderParts As Op
  ON o.OrderId = op.OrderId
  WHERE j.[Status] <> 'Finished'
  Group By p.PartId,p.[Description]
  HAVING SUM(pn.Quantity) > SUM(p.StockQty) + ISNULL(SUM(op.Quantity), 0)
  Order By p.PartId Asc


GO


CREATE FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL(16,2)
AS
  BEGIN
  RETURN(
		   Select ISNULL(SUM(p.Price * op.Quantity),0) AS Result
			 From Jobs As j
			 LEFT JOIN Orders As o
			 On j.JobId = o.JobId
			 LEFT JOIN OrderParts As op
			 ON o.OrderId = op.OrderId
			 LEFT JOIN Parts As p
			 ON p.PartId = op.PartId
			 Where j.JobId = @jobId
		 )
    END

GO

CREATE PROC usp_PlaceOrder
(@jobId INT, @serial VARCHAR(50), @quantity INT)
AS
BEGIN
IF (@jobId IN (SELECT JobId FROM Jobs WHERE Status = 'Finished')) THROW 50011, 'This job is not active!', 1
IF (@quantity <= 0) THROW 50012, 'Part quantity must be more than zero!', 1
IF (@jobId NOT IN (SELECT JobId FROM Jobs)) THROW 50013, 'Job not found!', 1
IF (@serial NOT IN (SELECT SerialNumber FROM Parts)) THROW 50014, 'Part not found!', 1

DECLARE @partId INT = (SELECT TOP(1) PartId FROM Parts WHERE SerialNumber = @serial)
DECLARE @orderId INT

IF (@jobId IN (SELECT JobId FROM Orders WHERE IssueDate IS NULL))
    BEGIN
    SET @OrderId = (SELECT TOP(1) OrderId FROM Orders WHERE JobId = @jobId)
    IF (@partId IN (SELECT PartId FROM OrderParts WHERE OrderId = @OrderId))
        BEGIN
        UPDATE OrderParts
            SET Quantity += @quantity 
            WHERE OrderId = @OrderId AND PartId = @partId
        RETURN
        END
    INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
    RETURN
    END

INSERT INTO Orders VALUES (@jobId, NULL, 0)
SET @orderId = (SELECT TOP(1) OrderId FROM Orders ORDER BY OrderId DESC)
INSERT INTO OrderParts VALUES (@OrderId, @partId, @quantity)
END