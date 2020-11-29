USE AdventureWorks2012;
GO

/*
	a) Создайте таблицу Person.CountryRegionHst, которая будет хранить информацию
	об изменениях в таблице Person.CountryRegion. Обязательные поля, которые должны
	присутствовать в таблице: ID — первичный ключ IDENTITY(1,1); Action — совершенное
	действие (insert, update или delete); ModifiedDate — дата и время, когда была совершена
	операция; SourceID — первичный ключ исходной таблицы; UserName — имя пользователя,
	совершившего операцию. Создайте другие поля, если считаете их нужными.
*/
CREATE TABLE Person.CountryRegionHst (
	ID INT IDENTITY(1,1) PRIMARY KEY,
	Action NVARCHAR(8) NOT NULL, 
	ModifiedDate DATETIME NOT NULL,
	SourceID NVARCHAR(3) NOT NULL,
	UserName NVARCHAR(25) NOT NULL
);
GO

/*
	b) Создайте три AFTER триггера для трех операций INSERT, UPDATE, DELETE для 
	таблицы Person.CountryRegion. Каждый триггер должен заполнять таблицу 
	Person.CountryRegionHst с указанием типа операции в поле Action.
*/
CREATE TRIGGER Person_Country_Region_Trigger
ON Person.CountryRegion
AFTER INSERT, UPDATE, DELETE   
AS
	IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
		INSERT INTO Person.CountryRegionHst 
		SELECT 
			'update',
			CURRENT_TIMESTAMP,
			CountryRegionCode,
			CURRENT_USER
		FROM inserted
	ELSE IF EXISTS (SELECT * FROM inserted)
		INSERT INTO Person.CountryRegionHst 
		SELECT 
			'insert',
			CURRENT_TIMESTAMP,
			CountryRegionCode,
			CURRENT_USER
		FROM inserted
	ELSE IF EXISTS (SELECT * FROM deleted)
		INSERT INTO Person.CountryRegionHst
		SELECT 
			'delete',
			CURRENT_TIMESTAMP,
			CountryRegionCode,
			CURRENT_USER
		FROM deleted;	
GO


INSERT INTO Person.CountryRegion (
	CountryRegionCode,
	Name,
	ModifiedDate
) VALUES (
	'WWW',
	'Warsaw',
	CURRENT_TIMESTAMP
);	
GO

SELECT * FROM Person.CountryRegionHst
WHERE SourceID = 'WWW';
GO

UPDATE Person.CountryRegion 
SET Name = 'Catowice' 
WHERE CountryRegionCode = 'WWW';	
GO

SELECT * FROM Person.CountryRegionHst
WHERE SourceID = 'WWW';
GO

DELETE FROM Person.CountryRegion
WHERE CountryRegionCode = 'WWW';
GO

SELECT * FROM Person.CountryRegionHst
WHERE SourceID = 'WWW';
GO

/*
	c) Создайте представление VIEW, отображающее все поля таблицы Person.CountryRegion.
	Сделайте невозможным просмотр исходного кода представления.
*/
CREATE VIEW CountryRegionView AS 
SELECT * FROM Person.CountryRegion;
GO

/*
	d) Вставьте новую строку в Person.CountryRegion через представление.
	Обновите вставленную строку. Удалите вставленную строку.
	Убедитесь, что все три операции отображены в Person.CountryRegionHst.
*/
INSERT INTO CountryRegionView (
	CountryRegionCode, 
	Name,
	ModifiedDate
) VALUES (
	'DDD',
	'Ukrainas',
	CURRENT_TIMESTAMP
);	
GO

SELECT * FROM CountryRegionView
WHERE CountryRegionCode = 'DDD';
GO


UPDATE CountryRegionView
SET Name = 'Irann' 
WHERE CountryRegionCode = 'DDD';	
GO

SELECT * FROM CountryRegionView
WHERE CountryRegionCode = 'DDD';
GO

DELETE FROM CountryRegionView
WHERE CountryRegionCode = 'DDD';
GO

SELECT * FROM Person.CountryRegionHst
WHERE SourceID = 'DDD';
GO
