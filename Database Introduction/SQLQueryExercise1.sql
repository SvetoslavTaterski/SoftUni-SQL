CREATE DATABASE Minions

CREATE TABLE Minions(
   Id int PRIMARY KEY IDENTITY,
   [Name] nvarchar(50),
   Age int,
)

CREATE TABLE Towns(
   Id int PRIMARY KEY IDENTITY,
   [Name] nvarchar(50)
)

ALTER TABLE Minions
ADD TownId int

ALTER TABLE Minions
ADD CONSTRAINT TownId
FOREIGN KEY (Id) REFERENCES Towns(Id);


INSERT INTO Towns([Name])
VALUES ('Sofia'),
       ('Plovdiv'),
	   ('Varna')

INSERT INTO Minions([Name],Age,TownId)
VALUES ('Kevin',22,1),
       ('Bob',15,3),
	   ('Steward',NULL,2)

TRUNCATE TABLE Minions

DROP TABLE Minions

DROP TABLE Towns

CREATE TABLE People(
Id int Primary Key IDENTITY,
[Name] nvarchar(200) NOT NULL,
Picture varbinary (MAX),
Height decimal(15,2),
[Weight] decimal(15,2),
Gender char(1) NOT NULL,
Birthdate datetime2 NOT NULL,
Biography nvarchar(MAX)
)

INSERT INTO People([Name],Picture,Height,[Weight],Gender,Birthdate,Biography)
VALUES('Svetoslav',NULL,1.82,85.00,'m','01-07-2002',NULL),
      ('Borislav',NULL,1.75,70.00,'m','01-07-2002',NULL),
	  ('Kristiana',NULL,1.85,72.00,'f','01-07-2002',NULL),
	  ('Vasil',NULL,1.80,80.00,'m','01-07-2002',NULL),
	  ('Hristo',NULL,1.80,80.00,'m','01-07-2002',NULL);


CREATE TABLE Users(
Id int PRIMARY KEY IDENTITY,
Username varchar(30) NOT NULL,
[Password] varchar(26) NOT NULL,
ProfilePicture varbinary(MAX),
LastLoginTime datetime2,
IsDeleted bit NOT NULL
)

INSERT INTO Users(Username,[Password],ProfilePicture,LastLoginTime,IsDeleted)
VALUES('Kilmi29','12345',NULL,'01-02-2023',0),
      ('Kilmi28','123456',NULL,'01-02-2023',0),
	  ('Kilmi27','123457',NULL,'01-02-2023',1),
	  ('Kilmi26','123458',NULL,'01-02-2023',0),
	  ('Kilmi25','123459',NULL,'01-02-2023',1)

ALTER TABLE Users
DROP CONSTRAINT PK__Users__3214EC0785270B01;

ALTER TABLE USERS
ADD CONSTRAINT PK_Users PRIMARY KEY (Id,Username);

ALTER TABLE USERS
ADD CHECK (LEN([Password]) >= 5)

Alter TABLE Users
ADD CONSTRAINT DF_LastLoginTime
DEFAULT CURRENT_TIMESTAMP FOR LastLoginTime;

Alter TABLE Users
Drop Constraint PK_Users

Alter Table Users
Add constraint PK_Id Primary key (Id);

Alter table Users
add constraint UC_Username UNIQUE (Username);

Alter table Users
add check (Len(Username)>=3);

Create database Movies

Create Table Directors(
Id int Primary Key Identity,
DirectorName nvarchar(50) NOT NULL,
Notes nvarchar(100)
)

Create Table Genres(
Id int Primary Key Identity,
GenreName nvarchar(50) NOT NULL,
Notes nvarchar(100)
)

Create Table Categories(
Id int Primary Key Identity,
CategoryName nvarchar(50) NOT NULL,
Notes nvarchar(100)
)

Create TABLE Movies(
Id int Primary key Identity,
Title nvarchar(100) NOT NULL,
DirectorId nvarchar(50) NOT NULL,
CopyrightYear datetime2 NOT NULL,
[Length] decimal (15,2) NOT NULL,
GenreId nvarchar(50) NOT NULL,
CategoryId nvarchar(50) NOT NULL,
Rating int NOT NULL,
Notes nvarchar(100)
)

Insert into Directors(DirectorName,Notes)
Values ('Svetli', NULL),
       ('Krisi', NULL),
	   ('Bore', NULL),
	   ('Nasko', NULL),
	   ('Ice', NULL)

Insert into Genres(GenreName,Notes)
VALUES ('Svetli', NULL),
       ('Krisi', NULL),
	   ('Bore', NULL),
	   ('Nasko', NULL),
	   ('Ice', NULL)

Insert into Categories(CategoryName,Notes)
Values ('Svetli', NULL),
       ('Krisi', NULL),
	   ('Bore', NULL),
	   ('Nasko', NULL),
	   ('Ice', NULL)

Insert into Movies(Title,DirectorId,CopyrightYear,[Length],GenreId,CategoryId,Rating,Notes)
Values('Movie1','Svetli','01-07-2002',1.30,'Genre1','Category1',100,NULL),
      ('Movie2','Svetli1','02-07-2002',1.35,'Genre2','Category2',99,NULL),
	  ('Movie3','Svetli2','03-07-2002',1.40,'Genre3','Category3',98,NULL),
	  ('Movie4','Svetli3','04-07-2002',1.45,'Genre4','Category4',97,NULL),
	  ('Movie5','Svetli4','05-07-2002',1.50,'Genre5','Category5',96,NULL)


Create DATABASE Hotel


Create TABLE Employees(
Id int PRIMARY KEY IDENTITY,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
Title nvarchar(50),
Notes nvarchar(100)
)

Insert into Employees(FirstName,LastName,Title,Notes)
VALUES ('Svetoslav','Taterski','Boss',NULL),
       ('Kristiana','Dishkova','CO-Boss',NULL),
	   ('Petko','Barakov',NULL,NULL)

Create Table Customers (
AccountNumber int Primary Key Identity,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
PhoneNumber int,
EmergencyName nvarchar(50) NOT NULL,
EmergencyNumber int NOT NULL,
Notes nvarchar(100)
)

Insert into Customers(FirstName,LastName,PhoneNumber,EmergencyName,EmergencyNumber,Notes)
VALUES('Svetoslav','Taterski',NULL,'SPESHNO',123,NULL),
      ('Svetoslav1','Taterski1',NULL,'SPESHNO1',1234,NULL),
	  ('Svetoslav2','Taterski2',NULL,'SPESHNO2',1235,NULL)

CREATE TABLE RoomStatus(
RoomStatus int primary key identity,
Notes nvarchar(50)
)

Insert into RoomStatus(Notes)
Values (NULL),
       ('Ima'),
	   ('Nema')

Create Table RoomTypes(
RoomType int primary key identity,
Notes nvarchar(50)
)

Insert into RoomTypes(Notes)
Values ('Ima'),
       ('nema'),
	   (Null)


Create Table BedTypes(
BedType int primary key identity,
Notes nvarchar(50)
)

Insert into BedTypes(Notes)
Values ('Ima'),
       ('nema'),
	   (Null)

Create Table Rooms(
RoomNumber int primary key identity,
RoomType int NOT NULL,
BedType int NOT NULL,
Rate int NOT NULL,
RoomStatus int NOT NULL,
Notes nvarchar(100)
)

Insert into Rooms(RoomType,BedType,Rate,RoomStatus,Notes)
Values (12,12,12,12,NULL),
       (13,13,13,13,NULL),
	   (14,14,14,14,NULL)

Create Table Payments(
Id int primary key identity,
EmployeeId int NOT NULL,
PaymentDate datetime2 NOT NULL,
AccountNumber int NOT NULL,
FirstDateOccupied datetime2 NOT NULL,
LastDateOccupied datetime2 NOT NULL,
TotalDays int NOT NULL,
AmountCharged decimal (15,2) NOT NULL,
TaxRate int,
TaxAmount int,
PaymentTotal int NOT NULL,
Notes nvarchar(100),
)

Insert into Payments
(EmployeeId,PaymentDate,AccountNumber,FirstDateOccupied,
 LastDateOccupied,TotalDays,AmountCharged,TaxRate,TaxAmount,PaymentTotal,Notes)
 Values (1,'01-01-2002',1,'01-01-2002','01-01-2002',1,12.30,NULL,NULL,13,NULL),
        (2,'02-01-2002',2,'02-01-2002','02-01-2002',2,13.30,NULL,NULL,15,NULL),
		(3,'03-01-2002',3,'03-01-2002','03-01-2002',3,14.30,NULL,NULL,16,NULL)

Create TABLE Occupancies(
Id int primary key identity,
EmployeeId int NOT NULL,
DateOccupied datetime2 NOT NULL,
AccountNumber int NOT NULL,
RoomNumber int NOT NULL,
RateApplied int NOT NULL,
PhoneCharge int NOT NULL,
Notes nvarchar
)

Insert into Occupancies(EmployeeId,DateOccupied,AccountNumber,RoomNumber,RateApplied,PhoneCharge,Notes)
VALUES (1,'01-01-2002',1,1,1,1,NULL),
       (2,'02-01-2002',2,2,2,2,NULL),
	   (3,'03-01-2002',3,3,3,3,NULL)

Create DATABASE CarRental

Create Table Categories(
Id INT PRIMARY KEY IDENTITY,
CategoryName nvarchar(50) NOT NULL,
DailyRate decimal (15,2) NOT NULL,
WeeklyRate decimal (15,2) NOT NULL,
MonthlyRate decimal (15,2) NOT NULL,
WeekendRate decimal (15,2) NOT NULL
)

Insert into Categories(CategoryName,DailyRate,WeeklyRate,MonthlyRate,WeekendRate)
Values ('Category1',5.00,5.00,5.00,5.00),
       ('Category2',6.00,6.00,6.00,6.00),
	   ('Category3',7.00,7.00,7.00,7.00)


Create TABLE Cars(
Id INT PRIMARY KEY IDENTITY,
PlateNumber int NOT NULL,
Manufacturer nvarchar(50) NOT NULL,
Model nvarchar(50) NOT NULL,
CarYear datetime2 NOT NULL,
CategoryId int NOT NULL,
Doors int NOT NULL,
Picture varbinary,
Condition nvarchar(50),
Available nvarchar(50)
)

Insert into Cars(PlateNumber,Manufacturer,Model,CarYear,CategoryId,Doors,Picture,Condition,Available)
Values (123,'BMW','X3','01-02-2022',1,4,NULL,NULL,NULL),
       (1234,'BMW','X4','01-03-2022',2,2,NULL,NULL,NULL),
	   (1235,'BMW','X5','01-04-2022',3,2,NULL,NULL,NULL)


Create TABLE Employees(
Id int PRIMARY KEY IDENTITY,
FirstName nvarchar(50) NOT NULL,
LastName nvarchar(50) NOT NULL,
Title nvarchar(50),
Notes nvarchar(100)
)

Insert into Employees(FirstName,LastName,Title,Notes)
VALUES ('Svetoslav','Taterski','Boss',NULL),
       ('Kristiana','Dishkova','CO-Boss',NULL),
	   ('Petko','Barakov',NULL,NULL)

Create Table Customers(
Id INT PRIMARY KEY IDENTITY,
DriverLicenceNumber int NOT NULL,
FullName nvarchar(50) NOT NULL,
[Address] nvarchar(50) NOT NULL,
City nvarchar(50) NOT NULL,
ZIPCode int NOT NULL,
Notes nvarchar(100)
)

Insert into Customers(DriverLicenceNumber,FullName,[Address],City,ZIPCode,Notes)
VALUES (1234,'Svetoslav Taterski','Geo Milev 5','Septemvri',4484,NULL),
       (12345,'Svetoslav Taterski2','Geo Milev 6','Septemvri2',4485,NULL),
	   (12346,'Svetoslav Taterski3','Geo Milev 7','Septemvri3',4486,NULL)


Create TABLE RentalOrders (
Id INT PRIMARY KEY IDENTITY,
EmployeeId INT NOT NULL,
CustomerId INT NOT NULL,
CarId INT NOT NULL,
TankLevel INT NOT NULL,
KilometrageStart INT NOT NULL,
KilometrageEnd INT NOT NULL,
TotalKilometrage INT NOT NULL,
StartDate datetime2 NOT NULL,
EndDate datetime2 NOT NULL,
TotalDays INT NOT NULL,
RateApplied decimal (15,2) NOT NULL,
TaxRate decimal (15,2) NOT NULL,
OrderStatus nvarchar(50) NOT NULL,
Notes nvarchar(100)
)

Insert into RentalOrders
(EmployeeId,CustomerId,CarId,TankLevel,KilometrageStart,KilometrageEnd,
TotalKilometrage,StartDate,EndDate,TotalDays,RateApplied,TaxRate,OrderStatus,Notes)
Values (1,1,1,1,1,1,1,'01-01-2002','02-02-2002',1,5.00,5.00,'done',NULL),
       (2,2,2,2,2,2,2,'01-01-2002','02-02-2002',2,5.00,5.00,'done',NULL),
	   (3,3,3,3,3,3,3,'01-01-2002','02-02-2002',3,5.00,5.00,'done',NULL)


Create DATABASE SoftUni

Create TABLE Towns(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

Create TABLE Addresses(
Id INT PRIMARY KEY IDENTITY,
AddressText NVARCHAR(50),
TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

Create TABLE Departments(
Id INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50)
)

Create TABLE Employees(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50) NOT NULL,
LastName NVARCHAR(50) NOT NULL,
JobTitle NVARCHAR(50) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
HireDate DATETIME2 NOT NULL,
Salary INT NOT NULL,
AddressId INT FOREIGN KEY REFERENCES Addresses(Id)
)


Insert Into Towns([Name])
VALUES ('Sofia'),
       ('Plovdiv'),
	   ('Varna'),
	   ('Burgas')

Insert Into Departments([Name])
VALUES ('Engineering'),
       ('Sales'),
	   ('Marketing'),
	   ('Software Development'),
	   ('Quality Assurance')

Insert INTO Employees(FirstName,MiddleName,LastName,JobTitle,DepartmentId,HireDate,Salary)
Values ('Ivan','Ivanov','Ivanov','.Net Developer',4,'01-01-2002',3500),
       ('Petar','Petrov','Petrov','Senior Engineer',1,'01-01-2002',4000),
	   ('Maria','Petrova','Ivanova','Intern',5,'01-01-2002',525),
	   ('Georgi','Teziev','Ivanov','CEO',2,'01-01-2002',3000),
	   ('Peter','Pan','Pan','Intern',3,'01-01-2002',599)


Select * from Towns

Select * from Departments

Select * from Employees


Select * from Towns
Order BY [Name] ASC

Select * from Departments
Order By [Name] ASC

Select * from Employees
Order By Salary DESC

Select [Name] from Towns
Order by [Name] ASC

Select [Name] from Departments
Order By [Name] ASC

Select FirstName,LastName,JobTitle,Salary from Employees
Order By Salary DESC

Update Employees
Set Salary += Salary *0.10;

Select Salary from Employees

Update Payments
Set TaxRate -= TaxRate * 0.03;

Select TaxRate from Payments

Delete From Occupancies