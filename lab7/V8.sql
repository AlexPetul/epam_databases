USE AdventureWorks2012;
GO

/*
	Вывести значения полей [AddressID], [City]из таблицы [Person].[Address]
	и полей [StateProvinceID] и [CountryRegionCode] из таблицы [Person].[StateProvince]
	в виде xml, сохраненного в переменную. Формат xml должен соответствовать примеру.
*/
DECLARE @xml XML;
SET @xml = ( 
	SELECT 
		AddressID AS [@ID],
		City,
		Province.StateProvinceID as 'Province/@ID',
		Province.CountryRegionCode as 'Province/Region'
	FROM 
		Person.Address as pa
		INNER JOIN Person.StateProvince as Province ON Province.StateProvinceID = pa.StateProvinceID
	WHERE AddressID = 532 or AddressID = 497
	ORDER BY Province.StateProvinceID DESC
	FOR XML PATH('Address'), ROOT('Addresses')
);
SELECT @xml;
GO

/*
	Создать хранимую процедуру, возвращающую таблицу, заполненную из xml 
	переменной представленного вида. Вызвать эту процедуру для заполненной
	на первом шаге переменной.
*/
CREATE PROCEDURE ParseXMLData(@x XML)
AS
BEGIN
	DECLARE @xml_doc INT;
	EXEC sp_xml_preparedocument @xml_doc OUTPUT, @x;
	SELECT * FROM 
	OPENXML(@xml_doc, '/Addresses/Address', 2)
	WITH (
		AddressID INT '@ID',
		City NVARCHAR(30),
		StateProvinceID INT 'Province/@ID',
		CountryRegionCode NVARCHAR(3) 'Province/Region'
	);
	EXEC sp_xml_removedocument @xml_doc;
END;
GO

DECLARE @xml XML;
SET @xml = ( 
	SELECT 
		AddressID AS [@ID],
		City,
		Province.StateProvinceID as 'Province/@ID',
		Province.CountryRegionCode as 'Province/Region'
	FROM 
		Person.Address as pa
		INNER JOIN Person.StateProvince as Province ON Province.StateProvinceID = pa.StateProvinceID
	WHERE AddressID = 532 or AddressID = 497
	ORDER BY Province.StateProvinceID DESC
	FOR XML PATH('Address'), ROOT('Addresses')
);
EXECUTE dbo.ParseXMLData @xml;
GO