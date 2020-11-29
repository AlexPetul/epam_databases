USE AdventureWorks2012;
GO

/*
	a)	создайте таблицу dbo.Address с такой же структурой как Person.Address, 
	кроме полей geography, uniqueidentifier, не включая индексы, ограничения и триггеры;
*/
CREATE TABLE dbo.Address (
	AddressID INT NOT NULL,
	AddressLine1 NVARCHAR(60) NOT NULL,
	AddressLine2 NVARCHAR(60) NULL,
	City NVARCHAR(30) NOT NULL,
	StateProvinceID INT FOREIGN KEY REFERENCES Person.StateProvince(StateProvinceID) NOT NULL,
	PostalCode NVARCHAR(15) NOT NULL,
	ModifiedDate DATETIME NOT NULL
);
GO

/*
	b) используя инструкцию ALTER TABLE, добавьте в таблицу dbo.Address 
	новое поле ID с типом данных INT, имеющее свойство identity с начальным 
	значением 1 и приращением 1. Создайте для нового поля ID ограничение UNIQUE;
*/
ALTER TABLE dbo.Address ADD ID INT IDENTITY(1,1) UNIQUE;
GO

/*
	c) Используя инструкцию ALTER TABLE, создайте для таблицы dbo.Address 
	ограничение для поля StateProvinceID, чтобы заполнить его можно было 
	только нечетными числами;
*/
ALTER TABLE dbo.Address
ADD CONSTRAINT Check_StateProvinceID
CHECK (StateProvinceId % 2 = 1);
GO

/*
	d) используя инструкцию ALTER TABLE, создайте для таблицы
	dbo.Address ограничение DEFAULT для поля AddressLine2, 
	задайте значение по умолчанию ‘Unknown’;
*/
ALTER TABLE dbo.Address
  ADD CONSTRAINT DF_AddressLine2
  DEFAULT 'Unknown' FOR AddressLine2;
GO

/*
	e) заполните новую таблицу данными из Person.Address. Выберите для 
	вставки только те адреса, где значение поля Name из таблицы CountryRegion 
	начинается на букву ‘а’. Также исключите данные, где StateProvinceID содержит 
	четные числа. Заполните поле AddressLine2 значениями по умолчанию;
*/
INSERT INTO dbo.Address (AddressID, AddressLine1, City, StateProvinceID, PostalCode, ModifiedDate)
SELECT
	pa.AddressID, 
	pa.AddressLine1,
	pa.City,
	pa.StateProvinceID,
	pa.PostalCode,
	pa.ModifiedDate
FROM Person.Address AS pa
INNER JOIN Person.StateProvince AS sp
ON sp.StateProvinceID = pa.StateProvinceID
INNER JOIN Person.CountryRegion AS cr
ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE LEFT(cr.Name, 1) = 'a' AND pa.StateProvinceID % 2 = 1;
GO

SELECT * FROM dbo.Address;
GO

/*
	f) измените поле AddressLine2, запретив вставку null значений.
*/
ALTER TABLE dbo.Address
ALTER COLUMN AddressLine2 NVARCHAR(60) NOT NULL;
GO

