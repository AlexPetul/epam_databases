USE AdventureWorks2012;
GO

/*
	a) добавьте в таблицу dbo.Address поле PersonName типа nvarchar размерностью 100 символов.
*/

ALTER TABLE dbo.Address ADD PersonName NVARCHAR(100);
GO


/*
	b) объявите табличную переменную с такой же структурой как dbo.Address
	и заполните ее данными из dbo.Address, где StateProvinceID = 77.
	Поле AddressLine2 заполните значениями из CountryRegionCode таблицы
	Person.CountryRegion, Name таблицы Person.StateProvince и City из Address.
	Разделите значения запятыми;
*/
DECLARE @personAddress TABLE (
	AddressID INT NOT NULL,
	AddressLine1 NVARCHAR(60) NOT NULL,
	AddressLine2 NVARCHAR(60) NOT NULL,
	City NVARCHAR(30) NOT NULL,
	StateProvinceID INT NOT NULL,
	PostalCode NVARCHAR(15) NOT NULL,
	ModifiedDate DATETIME NOT NULL,
	ID INT NOT NULL
);
INSERT INTO @personAddress 
SELECT
	AddressID, 
	AddressLine1,
	CONCAT(cr.Name, ',', sp.Name),
	City,
	addr.StateProvinceID,
	PostalCode,
	addr.ModifiedDate,
	ID
FROM dbo.Address AS addr
INNER JOIN Person.StateProvince as sp
ON sp.StateProvinceID = addr.StateProvinceID
INNER JOIN Person.CountryRegion as cr
ON cr.CountryRegionCode = sp.CountryRegionCode
WHERE addr.StateProvinceID = 77;

/*
	c) обновите поле AddressLine2 в dbo.Address данными из табличной переменной.
	Также обновите данные в поле PersonName данными из Person.Person,
	соединив значения полей FirstName и LastName;
*/

 UPDATE dbo.Address
 SET 
	dbo.Address.AddressLine2 = pa.AddressLine2,
	dbo.Address.PersonName = CONCAT(pp.FirstName, ' ', pp.LastName)
 FROM @personAddress AS pa
 INNER JOIN Person.BusinessEntityAddress AS persaddr
 ON persaddr.AddressID = pa.AddressID
 INNER JOIN Person.Person as pp
 ON pp.BusinessEntityID = persaddr.BusinessEntityID;

 SELECT * FROM dbo.Address;
 GO


  /*
	d) удалите данные из dbo.Address, которые относятся к типу ‘Main Office’
	из таблицы Person.AddressType;
 */
 DELETE FROM dbo.Address
 WHERE EXISTS (
	SELECT AddressID
	FROM Person.AddressType as at
	INNER JOIN Person.BusinessEntityAddress ba
	ON ba.AddressID = dbo.Address.AddressID
	WHERE ba.AddressTypeID = at.AddressTypeID AND Name = 'Main Office'
);
GO

 SELECT * FROM dbo.Address;
 GO


 /*
	e) удалите поле PersonName из таблицы, удалите все созданные ограничения и значения по умолчанию;
*/

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE
WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Address';
GO

SELECT *
FROM AdventureWorks2012.INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'dbo';
GO

ALTER TABLE dbo.Address 
DROP CONSTRAINT Check_StateProvinceID, DF_AddressLine2;
GO

ALTER TABLE dbo.Address
DROP COLUMN PersonName;
GO

/*
	f)	удалите таблицу dbo.Address.
*/

DROP TABLE dbo.Address;
GO