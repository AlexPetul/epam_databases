USE AdventureWorks2012;
GO

/*
	Создайте scalar-valued функцию, которая будет принимать в качестве входного параметра
	id подкатегории для продукта (Production.ProductSubcategory.ProductSubcategoryID)
	и возвращать количество продуктов указанной подкатегории (Production.Product).
*/
CREATE FUNCTION Production.getProductsBySubcategory(@dID INT)
RETURNS INT
AS
BEGIN
	RETURN (
		SELECT COUNT(*) 
		FROM Production.Product 
		WHERE ProductSubcategoryID = @dID
	);
END;
GO

PRINT Production.getProductsBySubcategory(1);
GO

SELECT *
FROM Production.Product
WHERE ProductSubcategoryID = 1;
GO

/*
	Создайте inline table-valued функцию, которая будет принимать в качестве входного
	параметра id подкатегории для продукта (Production.ProductSubcategory.ProductSubcategoryID),
	а возвращать список продуктов указанной подкатегории из Production.Product, стоимость которых
	более 1000 (StandardCost).
*/
CREATE FUNCTION Production.getProducts(@dID INT)
RETURNS TABLE
AS 
RETURN (
	SELECT * FROM Production.Product
	WHERE ProductSubcategoryID = @dID AND StandardCost > 1000
);
GO

SELECT * FROM Production.getProducts(1);
GO

/*
	Вызовите функцию для каждой подкатегории, применив оператор CROSS APPLY.
	Вызовите функцию для каждой подкатегории, применив оператор OUTER APPLY.
*/
SELECT * FROM Production.Product AS pr
CROSS APPLY
Production.getProducts(pr.ProductSubcategoryID) as prsub
ORDER BY pr.ProductSubcategoryID;
GO

SELECT * FROM Production.Product AS pr
OUTER APPLY
Production.getProducts(pr.ProductSubcategoryID) as prsub
ORDER BY pr.ProductSubcategoryID;
GO

/*
	Измените созданную inline table-valued функцию, сделав ее multistatement table-valued
	(предварительно сохранив для проверки код создания inline table-valued функции).
*/
CREATE FUNCTION Production.getProductsMulti(@dID INT)
RETURNS @products TABLE (
	ProductID SMALLINT NOT NULL,
	Name NVARCHAR(25) NOT NULL,
	ProductNumber NVARCHAR(25) NOT NULL,
	MakeFlag Flag,
	FinishedGoodsFlag Flag,
	Color NVARCHAR(15) NULL,
	SafetyStockLevel SMALLINT NOT NULL,
	ReorderPoint SMALLINT NOT NULL,
	StandartCost MONEY NOT NULL,
	ListPrice MONEY NOT NULL,
	Size NVARCHAR(5) NULL,
	SizeUnitMeasureCode NCHAR(3) NULL,
	WeightUnitMeasureCode NCHAR(3) NULL,
	Weight DECIMAL(8,2) NULL,
	DaysToManufacture INT NOT NULL,
	ProductLine NCHAR(2) NULL,
	Class NCHAR(2) NULL,
	Style NCHAR(2) NULL,
	ProductSubCategoryID INT NULL,
	ProductModelID INT NULL,
	SellStartDate DATETIME NOT NULL,
	SellEndDate DATETIME NULL,
	DiscontinuedDate DATETIME NULL,
	rowguid UNIQUEIDENTIFIER NOT NULL,
	ModifiedDate DATETIME NOT NULL
) AS
BEGIN
	INSERT INTO @products
	SELECT *
	FROM Production.Product 
	WHERE ProductSubcategoryID = @dID AND StandardCost > 1000
	RETURN;
END;
GO

SELECT *
FROM Production.getProductsMulti(1);
GO
