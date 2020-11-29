USE AdventureWorks2012;
GO

/*
	Создайте хранимую процедуру, которая будет возвращать сводную таблицу (оператор PIVOT),
	отображающую данные о суммарном количестве заказанных продуктов
	(Production.WorkOrder.OrderQty) за определенный месяц (DueDate).
	Вывести информацию необходимо для каждого года. Список месяцев передайте в процедуру
	через входной параметр.

	Таким образом, вызов процедуры будет выглядеть следующим образом:
	EXECUTE dbo.WorkOrdersByMonths ‘[January],[February],[March],[April],[May],[June]’
*/
CREATE PROCEDURE dbo.getQtyByMonths
@MONTHS NVARCHAR(1000)
AS
	DECLARE @query NVARCHAR(1000);	
	SET @query = 'SELECT	[Year],' + @MONTHS + '
	FROM	
	(
		SELECT OrderQty, FORMAT(DueDate, ''yyyy'') AS [Year], FORMAT(DueDate, ''MMMM'') AS [Month]
		FROM Production.WorkOrder
	) AS SOURCE
	PIVOT
	(
		SUM(OrderQty) FOR [Month] IN (' + @MONTHS +')
	) pvt'
	EXEC sp_executesql @query
GO

EXECUTE dbo.getQtyByMonths '[January],[February],[March],[April],[May],[June]'
