USE AdventureWorks2012;
GO

/*
	Вывести на экран список сотрудников которые подавали резюме при трудоустройстве.
*/

SELECT empl.BusinessEntityID, OrganizationLevel, JobTitle, jc.JobCandidateID, jc.Resume
FROM HumanResources.Employee as empl
INNER JOIN HumanResources.JobCandidate as jc
ON empl.BusinessEntityID = jc.BusinessEntityID
WHERE jc.Resume IS NOT NULL;
GO

/*
	Вывести на экран названия отделов, в которых работает более 10-ти сотрудников
*/

SELECT DISTINCT dep.DepartmentID, Name, COUNT(empl.emplcount) as EmplCount
FROM HumanResources.Department as dep
INNER JOIN (
				SELECT
					DepartmentID,
					BusinessEntityID
				FROM HumanResources.EmployeeDepartmentHistory
				GROUP BY BusinessEntityID, DepartmentID
			) empldep ON empldep.DepartmentID = dep.DepartmentID
INNER JOIN (
				SELECT
					BusinessEntityId,
					COUNT(BusinessEntityID) as emplcount
				FROM HumanResources.Employee
				GROUP BY BusinessEntityID
			) empl ON empldep.BusinessEntityID = empl.BusinessEntityID
GROUP BY dep.DepartmentID, Name
HAVING COUNT(empl.emplcount) > 10
GO

/*
	Вывести на экран накопительную сумму часов отпуска по 
	причине болезни (SickLeaveHours) в рамках каждого отдела. 
	Сумма должна накапливаться по мере трудоустройства сотрудников (HireDate).
*/

SELECT 
	dep.Name, empl.HireDate,
	empl.SickLeaveHours,
	coalesce(sum(empl.SickLeaveHours) over 
		(partition by Name order by Name rows between unbounded preceding and current row), 0) AccumulativeSum
FROM HumanResources.Department as dep
INNER JOIN HumanResources.EmployeeDepartmentHistory as emplhst
ON emplhst.DepartmentID = dep.DepartmentID
INNER JOIN (
	SELECT BusinessEntityID, HireDate, SickLeaveHours
		FROM HumanResources.Employee
		GROUP BY BusinessEntityID, SickLeaveHours, HireDate
	) AS empl ON empl.BusinessEntityID = emplhst.BusinessEntityID
GROUP BY dep.Name, empl.HireDate, empl.SickLeaveHours;
GO