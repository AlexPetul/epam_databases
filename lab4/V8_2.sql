USE AdventureWorks2012;
GO

/*
	a) Создайте представление VIEW, отображающее данные из таблиц Person.CountryRegion
	и Sales.SalesTerritory. Создайте уникальный кластерный индекс в представлении по
	полю TerritoryID.
*/
CREATE VIEW CountryRegionInfoView 
WITH SCHEMABINDING, ENCRYPTION AS 
SELECT 
	cr.CountryRegionCode,
	cr.Name as RegionName,
	cr.ModifiedDate as RegionModified,
	st.TerritoryID,
	st.Name as TerritoryName,
	st.[Group] as Gr,
	st.SalesYTD,
	st.SalesLastYear,
	st.CostYTD,
	st.CostLastYear,
	st.rowguid,
	st.ModifiedDate as TerritoryModified
FROM Person.CountryRegion AS cr
INNER JOIN Sales.SalesTerritory AS st
ON cr.CountryRegionCode = st.CountryRegionCode
GO

CREATE UNIQUE CLUSTERED INDEX CountryRegionInfo_UC
	ON CountryRegionInfoView(TerritoryID); 
GO

/*
	b) Создайте один INSTEAD OF триггер для представления на три операции
	INSERT, UPDATE, DELETE. Триггер должен выполнять соответствующие
	операции в таблицах Person.CountryRegion и Sales.SalesTerritory.
*/
CREATE TRIGGER CRUD_TRIGGER
ON CountryRegionInfoView
INSTEAD OF INSERT, UPDATE, DELETE
AS
BEGIN
	IF NOT EXISTS (SELECT * FROM INSERTED)
	BEGIN
		DECLARE @crr NVARCHAR(3);
		SELECT @crr = DELETED.CountryRegionCode FROM DELETED;

		DELETE FROM Sales.SalesTerritory
		WHERE CountryRegionCode = @crr;
			
		DELETE FROM Person.CountryRegion
		WHERE CountryRegionCode = @crr;
	END ELSE IF NOT EXISTS (SELECT * FROM DELETED)
	BEGIN
		IF NOT EXISTS	(SELECT * 
						FROM	Person.CountryRegion AS PCR 
						JOIN	INSERTED
						ON		INSERTED.CountryRegionCode = PCR.CountryRegionCode)

			INSERT INTO Person.CountryRegion(
				CountryRegionCode,
				Name,
				ModifiedDate
			) SELECT	INSERTED.CountryRegionCode,
						INSERTED.RegionName,
						INSERTED.RegionModified
						FROM INSERTED;
		ELSE
			UPDATE Person.CountryRegion
			SET	Name = INSERTED.RegionName,
				ModifiedDate = INSERTED.RegionModified
			FROM INSERTED
			WHERE Person.CountryRegion.CountryRegionCode = INSERTED.CountryRegionCode;

		INSERT INTO Sales.SalesTerritory (
			Name,
			CountryRegionCode,
			[Group],
			SalesYTD,
			SalesLastYear,
			CostYTD,
			CostLastYear,
			ModifiedDate
		)SELECT INSERTED.TerritoryName,
				INSERTED.CountryRegionCode,
				INSERTED.[Gr],
				INSERTED.SalesYTD,
				INSERTED.SalesLastYear,
				INSERTED.CostYTD,
				INSERTED.CostLastYear,
				INSERTED.TerritoryModified
		FROM INSERTED;
	END
	ELSE
	BEGIN
		UPDATE Person.CountryRegion
		SET Name = INSERTED.RegionName,
			ModifiedDate = INSERTED.RegionModified
		FROM Person.CountryRegion AS PCR
		JOIN INSERTED 
		ON PCR.CountryRegionCode = INSERTED.CountryRegionCode;

		UPDATE Sales.SalesTerritory
		SET Name = INSERTED.TerritoryName,
			[Group] = INSERTED.[Gr],
			SalesYTD= INSERTED.SalesYTD,
			SalesLastYear= INSERTED.SalesLastYear,
			CostYTD= INSERTED.CostYTD,
			CostLastYear= INSERTED.CostLastYear,
			ModifiedDate = INSERTED.TerritoryModified
		FROM Sales.SalesTerritory AS ST
		JOIN INSERTED
		ON ST.TerritoryID = INSERTED.TerritoryID;
	END
END

/*
	c) вставьте новую строку в представление, указав новые данные для 
	CountryRegion и SalesTerritory. триггер должен добавить новые строки 
	в таблицы Person.CountryRegion и Sales.SalesTerritory. 
	обновите вставленные строки через представление. удалите строки.
*/
INSERT INTO CountryRegionInfoView
(
	RegionModified,
	TerritoryName,
	CountryRegionCode,
	RegionName,
	[Gr],
	SalesYTD,
	SalesLastYear,
	CostYTD,
	CostLastYear,
	rowguid,
	TerritoryModified
) VALUES (
	GETDATE(),
	'Bobruiskk',
	'BEL',
	'Bobruisik',
	'RU',
	3232.3,
	26.0,
	218.0,
	132.0,
	NEWID(),
	GETDATE()
);

UPDATE CountryRegionInfoView
SET	RegionName = 'Bobruiskk',
	[Gr] ='RU',
	SalesLastYear = 333.0
WHERE CountryRegionCode = 'BEL';

DELETE FROM CountryRegionInfoView
WHERE CountryRegionCode = 'BEL';