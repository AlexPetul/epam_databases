USE AdventureWorks2012;
GO

/*
	Вывести на экран холостых сотрудников, 
	которые родились раньше 1960 года (включая 1960 год).
*/
SELECT BusinessEntityID, BirthDate, MaritalStatus, Gender, HireDate 
FROM HumanResources.Employee
WHERE MaritalStatus = 'S' and Year(BirthDate) <= 1960;
GO


/*
	Вывести на экран сотрудников, работающих на позиции ‘Design Engineer’,
	отсортированных в порядке убывания принятия их на работу.
*/
SELECT BusinessEntityID, JobTitle, BirthDate, Gender, HireDate 
FROM HumanResources.Employee
WHERE JobTitle = 'Design Engineer' ORDER BY HireDate DESC;
GO
	
/*
	Вывести на экран сотрудников, которым исполнилось 18 лет в тот год, когда их приняли на работу.
*/
SELECT TOP 5 BusinessEntityID, JobTitle, Gender, BirthDate, HireDate 
FROM HumanResources.Employee
WHERE DATEDIFF(YEAR, BirthDate, HireDate) > 18;
GO