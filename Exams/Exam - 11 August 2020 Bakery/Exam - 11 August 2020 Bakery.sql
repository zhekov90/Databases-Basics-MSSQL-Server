
--1.	Database design

CREATE TABLE Countries
(
   Id  INT PRIMARY KEY IDENTITY,
   [Name] NVARCHAR(50) UNIQUE
)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25),
	LastName NVARCHAR(25),
	Gender CHAR(1) CHECK(Gender IN('M', 'F')),
	Age INT,
	PhoneNumber CHAR(10),
	CountryId INT REFERENCES Countries(Id)
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	[Description] NVARCHAR(250),
	Recipe NVARCHAR(MAX),
	Price MONEY CHECK(Price >= 0)
)

CREATE TABLE Feedbacks
(
	Id INT PRIMARY KEY IDENTITY,
	[Description] NVARCHAR(255),
	Rate DECIMAL(4, 2) CHECK(Rate >= 0 AND Rate <= 10),
	ProductId INT REFERENCES Products(Id),
	CustomerId INT REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
	Id INT PRIMARY KEY IDENTITY,
	[Name] NVARCHAR(25) UNIQUE,
	AddressText NVARCHAR(30),
	Summary NVARCHAR(200),
	CountryId INT REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(30),
	[Description] NVARCHAR(200),
	OriginCountryId INT REFERENCES Countries(Id),
	DistributorId INT REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
	ProductId INT REFERENCES Products(Id),
	IngredientId INT REFERENCES Ingredients(Id),
	PRIMARY KEY(ProductId, IngredientId)
)


--2.	Insert

INSERT INTO Distributors([Name], CountryId, AddressText, Summary)
VALUES
('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers(FirstName, LastName, Age, Gender, PhoneNumber, CountryId)
VALUES
('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
('Kendra', 'Loud', 22, 'F', '0063631526', 11),
('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
('Tom', 'Loeza', 31, 'M', '0144876096', 23),
('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
('Josefa', 'Opitz', 43, 'F', '0197887645', 17)


--3.	Update

UPDATE Ingredients
SET DistributorId = 35
WHERE [Name] IN('Bay Leaf', 'Paprika', 'Poppy')

UPDATE Ingredients
SET OriginCountryId = 14
WHERE OriginCountryId = 8


--4.	Delete

DELETE Feedbacks
WHERE CustomerId = 14 OR ProductId = 5


--5.	Products by Price

SELECT [Name], Price, [Description] FROM Products
ORDER BY Price DESC, [Name]


--6.	Negative Feedback

SELECT f.ProductId, f.Rate, f.[Description], c.Id, c.Age, c.Gender FROM Feedbacks AS f
JOIN Customers AS c ON c.Id = f.CustomerId
WHERE f.Rate < 5.0
ORDER BY f.ProductId DESC, f.Rate


--7.	Customers without Feedback

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName, c.PhoneNumber, c.Gender FROM Customers AS c
LEFT JOIN Feedbacks AS f ON f.CustomerId = c.Id
WHERE f.CustomerId IS NULL
ORDER BY c.Id


--8.	Customers by Criteria

SELECT cu.FirstName, cu.Age, cu.PhoneNumber FROM Customers AS cu
JOIN Countries AS c ON c.Id = cu.CountryId
WHERE cu.Age >= 21 AND cu.FirstName LIKE '%an%' OR RIGHT(cu.PhoneNumber, 2) = '38'
ORDER BY cu.FirstName, cu.Age DESC


--9.	Middle Range Distributors

SELECT d.[Name] AS DistributorName, i.[Name] AS IngredientName, p.[Name] AS ProductName, AVG(f.Rate) AS AverageRate FROM ProductsIngredients AS pi
JOIN Products AS p ON p.Id = pi.ProductId
JOIN Ingredients AS i ON i.Id = pi.IngredientId
JOIN Distributors AS d ON d.Id = i.DistributorId
JOIN Feedbacks AS f ON f.ProductId = p.Id
GROUP BY d.[Name], i.[Name], p.[Name]
HAVING AVG(f.Rate) BETWEEN 5 AND 8
ORDER BY d.[Name], i.[Name], p.[Name]


--10.	Country Representative

SELECT CountryName, DisributorName
	FROM
	(
		SELECT c.Name AS CountryName,
        d.Name AS DisributorName,
        COUNT(i.DistributorId) AS IngredientsByDistributor,
        DENSE_RANK() OVER(PARTITION BY c.Name ORDER BY COUNT(i.DistributorId) DESC) AS [Rank]
		FROM Countries AS c
        LEFT JOIN Distributors AS d ON d.CountryId = c.Id
        LEFT JOIN Ingredients AS i ON i.DistributorId = d.Id
		GROUP BY c.Name, d.Name
	) AS ranked
WHERE Rank = 1
ORDER BY CountryName, DisributorName