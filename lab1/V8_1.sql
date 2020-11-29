USE master;
GO

CREATE DATABASE NewDatabase;
GO

USE NewDatabase;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA persons;
GO

CREATE TABLE sales.Orders (OrderNum INT NULL);
GO

BACKUP DATABASE NewDatabase TO DISK = 'Alex_Petul.bak';
GO

USE MASTER;
GO

DROP DATABASE NewDatabase;
GO

RESTORE DATABASE NewDatabase FROM DISK = 'Alex_Petul.bak';
GO