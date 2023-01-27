Create DATABASE [TableRelations]


Create Table Passports(
PassportID INT PRIMARY KEY IDENTITY(101,1),
PassportNumber NVARCHAR(50) NOT NULL
)

Create Table Persons(
PersonID INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
Salary DECIMAL(15,2) NOT NULL,
PassportID INT FOREIGN KEY REFERENCES Passports(PassportID)
)

Create Table Manufacturers(
ManufacturerID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
EstablishedOn DATETIME2 NOT NULL
)

Create Table Models(
ModelID INT PRIMARY KEY IDENTITY(101,1),
[Name] NVARCHAR(50) NOT NULL,
ManufacturerID INT FOREIGN KEY REFERENCES Manufacturers(ManufacturerID)
)

Create Table Students(
StudentID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

Create Table Exams(
ExamID INT PRIMARY KEY IDENTITY(101,1),
[Name] NVARCHAR(50) NOT NULL
)

Create Table StudentsExams(
StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
ExamID INT FOREIGN KEY REFERENCES Exams(ExamID),
PRIMARY KEY(StudentID,ExamID)
)

Create Table Teachers(
TeacherID INT PRIMARY KEY IDENTITY(101,1),
[Name] NVARCHAR(50) NOT NULL,
ManagerID INT FOREIGN KEY REFERENCES Teachers(TeacherID)
)

Create Table ItemTypes(
ItemTypeID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

Create Table Cities(
CityID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL
)

Create Table Items(
ItemID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
ItemTypeID INT FOREIGN KEY REFERENCES ItemTypes(ItemTypeID) 
)

Create Table Customers(
CustomerID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR(50) NOT NULL,
BirthDay DATETIME2 NOT NULL,
CityID INT FOREIGN KEY REFERENCES Cities(CityID)
)

Create Table Orders(
OrderID INT PRIMARY KEY IDENTITY,
CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
)

Create Table OrderItems(
OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
ItemID INT FOREIGN KEY REFERENCES Items(ItemID),
PRIMARY KEY (OrderID,ItemID)
)

Create DATABASE University

Create Table Majors(
MajorID INT PRIMARY KEY IDENTITY,
[Name] NVARCHAR NOT NULL
)

Create Table Students(
StudentID INT PRIMARY KEY IDENTITY,
StudentNumber INT NOT NULL,
StudentName NVARCHAR(50) NOT NULL,
MajorID INT FOREIGN KEY REFERENCES Majors(MajorID)
)

Create Table Payments(
PaymentID INT PRIMARY KEY IDENTITY,
PaymentDate DATETIME2 NOT NULL,
PaymentAmount DECIMAL(15,2) NOT NULL,
StudentID INT FOREIGN KEY REFERENCES Students(StudentID)
)

Create Table Subjects(
SubjectID INT PRIMARY KEY IDENTITY,
SubjectName NVARCHAR(50) NOT NULL
)

Create Table Agenda(
StudentID INT FOREIGN KEY REFERENCES Students(StudentID),
SubjectID INT FOREIGN KEY REFERENCES Subjects(SubjectID),
PRIMARY KEY (StudentID,SubjectID)
)

   Select m.MountainRange,
          p.PeakName,
	      p.Elevation
     From Peaks
       As p
Left Join Mountains
       As m
	   On p.MountainId = m.Id
    Where m.MountainRange = 'Rila'
 Order By p.Elevation DESC