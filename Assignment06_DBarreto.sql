--*************************************************************************--
-- Title: Assignment06
-- Author: DBarreto
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-01-01,YourNameHere,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DBarreto')
	 Begin 
	  Alter Database [Assignment06DB_DBarreto] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DBarreto;
	 End
	Create Database Assignment06DB_DBarreto;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DBarreto;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

--CREATE VIEW vCategories AS
--SELECT CategoryID, CategoryName
--FROM Categories;

--DROP VIEW vCategories; 

CREATE VIEW vCategories 
WITH SCHEMABINDING
AS
SELECT CategoryID,CategoryName
FROM dbo.Categories;
go

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT ProductID, ProductName, CategoryID, UnitPrice
FROM dbo.Products;
go

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
FROM dbo.Employees;
go

CREATE VIEW vInventories 
WITH SCHEMABINDING
AS
SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
FROM dbo.Inventories;
go



-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories to Public;
go

GRANT SELECT ON vCategories to public;
go

DENY SELECT ON Products to Public;
go

GRANT SELECT ON vProducts to public;
go

DENY SELECT ON Employees to Public;
go

GRANT SELECT ON vEmployees to public;
go

DENY SELECT ON Inventories to Public;
go

GRANT SELECT ON vInventories to public;
go

-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

--SELECT * from Categories
--SELECT * from Products

CREATE VIEW vProductsByCategories AS
SELECT CategoryName, ProductName, UnitPrice
FROM dbo.Categories
INNER JOIN Products
ON Categories.CategoryID= Products.CategoryID;
go

SELECT CategoryName, ProductName, UnitPrice
FROM vProductsByCategories
ORDER BY CategoryName, ProductName;
go


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDates AS
SELECT ProductName, InventoryDate, Count
FROM dbo.Products
INNER JOIN Inventories 
ON Products.ProductID=Inventories.ProductID;
go

SELECT ProductName, InventoryDate, Count
FROM vInventoriesByProductsByDates
ORDER BY ProductName, InventoryDate, Count;
go


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

CREATE VIEW vInventoriesByEmployeesByDates AS
SELECT DISTINCT 
[EmployeeName]= a.EmployeeFirstName+''+a.EmployeeLastName
,[InventoryDate]= b.InventoryDate
FROM dbo.Employees AS a
INNER JOIN Inventories AS b
ON a.EmployeeID=b.EmployeeID;
go

SELECT DISTINCT 
[InventoryDate],[EmployeeName]
FROM vInventoriesByEmployeesByDates
ORDER BY InventoryDate;
go


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories AS
SELECT CategoryName,ProductName, InventoryDate, Count
FROM Products
INNER JOIN Categories 
ON Products.CategoryID=Categories.CategoryID
INNER JOIN Inventories
ON Products.ProductID=Inventories.ProductID;
go


SELECT CategoryName,ProductName, InventoryDate, Count
FROM vInventoriesByProductsByCategories 
ORDER BY CategoryName, ProductName, InventoryDate, Count;
go

-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees AS
SELECT 
[CategoryName]=a.CategoryName
,[ProductName]=b.ProductName
,[InventoryDate]=c.InventoryDate
,[Count]=c.Count
,[EmployeeName]=e.EmployeeFirstName+''+e.EmployeeLastName
FROM dbo.Categories as a
INNER JOIN Products as b
ON a.CategoryID=b.CategoryID
INNER JOIN Inventories as c
ON b.ProductID=c.ProductID
INNER JOIN Employees as e
ON c.EmployeeID=e.EmployeeID
go

SELECT CategoryName,ProductName, InventoryDate,EmployeeName, Count
FROM vInventoriesByProductsByEmployees
ORDER BY InventoryDate, CategoryName, ProductName, EmployeeName,Count;
go

-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployees AS
SELECT 
[CategoryName]=a.CategoryName
,[ProductName]=b.ProductName
,[InventoryDate]=c.InventoryDate
,[Count]=c.Count
,[EmployeeName]=e.EmployeeFirstName+''+e.EmployeeLastName
FROM dbo.Categories as a
INNER JOIN Products as b
ON a.CategoryID=b.CategoryID
INNER JOIN Inventories as c
ON b.ProductID=c.ProductID
INNER JOIN Employees as e
ON c.EmployeeID=e.EmployeeID
WHERE ProductName IN ('Chai','Chang')
go


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager AS
SELECT 
[Employee]=e.EmployeeFirstName+''+e.EmployeeLastName,
[Manager]=m.EmployeeFirstName+''+e.EmployeeLastName
FROM dbo.Employees as e
LEFT OUTER JOIN Employees as m
ON e.ManagerID=m.EmployeeID
go

SELECT Employee, Manager
FROM vEmployeesByManager
ORDER BY Manager;
go



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

--CREATE VIEW vCategoriesByProductsByInventoriesByEmployeesByBASICVIEWS AS
--SELECT 
--[CategoryID]=c.CategoryID
--,[CategoryName]=c.CategoryName
--,[ProductID]=p.ProductID
--,[ProductName]=p.ProductName
--,[UnitPrice]=p.UnitPrice
--,[InventoryDate]=i.InventoryDate
--,[Count]=i.Count
--,[EmployeeID]=e.EmployeeID
--,[Employee]=e.EmployeeFirstName+''+e.EmployeeLastName
--,[Manager]=m.EmployeeFirstName+''+m.EmployeeLastName
--FROM Categories AS c
--INNER JOIN Products AS p
--ON c.CategoryID=p.CategoryID
--INNER JOIN Inventories AS i
--ON i.ProductID=p.ProductID
--INNER JOIN Employees AS e
--ON e.EmployeeID=i.EmployeeID
--INNER JOIN Employees AS m
--ON e.ManagerID=m.EmployeeID;
--go

--DROP VIEW vCategoriesByProductsByInventoriesByEmployeesByBASICVIEWS; -- DROP view because forgot one column (inventoryID)

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees AS
SELECT 
[CategoryID]=c.CategoryID
,[CategoryName]=c.CategoryName
,[ProductID]=p.ProductID
,[ProductName]=p.ProductName
,[UnitPrice]=p.UnitPrice
,[InventoryID]=i.InventoryID
,[InventoryDate]=i.InventoryDate
,[Count]=i.Count
,[EmployeeID]=e.EmployeeID
,[Employee]=e.EmployeeFirstName+''+e.EmployeeLastName
,[Manager]=m.EmployeeFirstName+''+m.EmployeeLastName
FROM Categories AS c
INNER JOIN Products AS p
ON c.CategoryID=p.CategoryID
INNER JOIN Inventories AS i
ON i.ProductID=p.ProductID
INNER JOIN Employees AS e
ON e.EmployeeID=i.EmployeeID
INNER JOIN Employees AS m
ON e.ManagerID=m.EmployeeID;
go

SELECT CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
FROM vInventoriesByProductsByCategoriesByEmployees
ORDER BY CategoryName, ProductID, InventoryID, Employee;
go 
-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories] --Q3
Select * From [dbo].[vInventoriesByProductsByDates]--Q4
Select * From [dbo].[vInventoriesByEmployeesByDates]--Q5
Select * From [dbo].[vInventoriesByProductsByCategories]--Q6
Select * From [dbo].[vInventoriesByProductsByEmployees]--Q7
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]--Q8
Select * From [dbo].[vEmployeesByManager]--Q9
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]--Q10

/***************************************************************************************/