--*************************************************************************--
-- Title: Assignment06
-- Author: Gabriela Tedeschi
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-05-15,G Tedeschi,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_GTedeschi')
	 Begin 
	  Alter Database [Assignment06DB_GTedeschi] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_GTedeschi;
	 End
	Create Database Assignment06DB_GTedeschi;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_GTedeschi;

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
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
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
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!

CREATE VIEW vCategories
WITH SCHEMABINDING
AS
	SELECT CategoryID, CategoryName
	 FROM dbo.Categories;
GO

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
	SELECT ProductID, ProductName, CategoryID, UnitPrice
	 FROM dbo.Products;
GO

CREATE VIEW vEmployees
WITH SCHEMABINDING
AS
	SELECT EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
	 FROM dbo.Employees;
GO

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
	SELECT InventoryID, InventoryDate, EmployeeID, ProductID, Count
	 FROM dbo.Inventories;
GO


-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

DENY SELECT ON Categories to Public;
GO
GRANT SELECT ON vCategories to Public;
GO

DENY SELECT ON Products to Public;
GO
GRANT SELECT ON vProducts to Public;
GO

DENY SELECT ON Employees to Public;
GO
GRANT SELECT ON vEmployees to Public;
GO

DENY SELECT ON Inventories to Public;
GO
GRANT SELECT ON vInventories to Public;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

CREATE VIEW vProductsByCategories
AS
	SELECT TOP 10000 CategoryName, ProductName, UnitPrice
	 FROM vCategories AS c
	 JOIN vProducts AS p
	  ON c.CategoryID = p.CategoryID
	   ORDER BY CategoryName, ProductName;
GO
   

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByDates
AS
	SELECT TOP 10000 ProductName, Count, InventoryDate
	 FROM vProducts AS p
	 JOIN vInventories AS i
	  ON p.ProductID = i.ProductID
	   ORDER BY ProductName, InventoryDate, Count;
GO
   

-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE VIEW vInventoriesByEmployeesByDates
AS
	SELECT DISTINCT TOP 10 InventoryDate, [EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	 FROM vInventories AS i
	 JOIN vEmployees AS e
	  ON i.EmployeeID = e.EmployeeID
	   ORDER BY InventoryDate;
GO


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW vInventoriesByProductsByCategories
AS
	SELECT TOP 10000 CategoryName, ProductName, InventoryDate, Count
	 FROM vCategories AS c
	 JOIN vProducts AS p
	  ON c.CategoryID = p.CategoryID
	 JOIN vInventories AS i
	  ON p.ProductID = i.ProductID
	   ORDER BY CategoryName, ProductName, InventoryDate, Count;
GO


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW vInventoriesByProductsByEmployees
AS
	SELECT TOP 10000 
		CategoryName, 
		ProductName, 
		InventoryDate, 
		Count, 
		[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
	 FROM vCategories AS c
	 JOIN vProducts AS p
	  ON c.CategoryID = p.CategoryID
	 JOIN vInventories AS i
	  ON p.ProductID = i.ProductID
	 JOIN vEmployees AS e
	  ON i.EmployeeID = e.EmployeeID
	   ORDER BY 
		InventoryDate, 
		CategoryName, 
		ProductName, 
		EmployeeFirstName + ' ' + EmployeeLastName;
GO


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
	SELECT TOP 10000 
			CategoryName, 
			ProductName, 
			InventoryDate, 
			Count, 
			[EmployeeName] = EmployeeFirstName + ' ' + EmployeeLastName
		 FROM vCategories AS c
		 JOIN vProducts AS p
		  ON c.CategoryID = p.CategoryID
		 JOIN vInventories AS i
		  ON p.ProductID = i.ProductID
		 JOIN vEmployees AS e
		  ON i.EmployeeID = e.EmployeeID
		   WHERE ProductName = 'Chai' OR ProductName = 'Chang'
			ORDER BY InventoryDate, ProductName;
GO


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW vEmployeesByManager
AS 
	SELECT TOP 100
		[ManagerName] = m.EmployeeFirstName + ' ' + m.EmployeeLastName,
		[EmployeeName] = e.EmployeeFirstName + ' ' + e.EmployeeLastName
	 FROM vEmployees AS e
	 JOIN vEmployees AS m
	  ON e.ManagerID = m.EmployeeID
	   ORDER BY m.EmployeeFirstName + ' ' + m.EmployeeLastName;
GO


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views?

CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
	SELECT
		c.CategoryID,
		CategoryName,
		p.ProductID,
		ProductName,
		UnitPrice,
		InventoryID,
		InventoryDate,
		Count,
		e.EmployeeID,
		[Employee] = e.EmployeeFirstName + ' ' + e.EmployeeLastName,
		[Manager] = m.EmployeeFirstName + ' ' + m.EmployeeLastName
	 FROM vCategories AS c
	 JOIN vProducts AS p
	  ON c.CategoryID = p.CategoryID
	 JOIN vInventories AS i
	  ON p.ProductID = i.ProductID
	 JOIN vEmployees AS e
	  ON i.EmployeeID = e.EmployeeID
	 JOIN vEmployees AS m
	  ON e.ManagerID = m.EmployeeID;
GO


-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From vCategories;
Select * From vProducts;
Select * From vInventories;
Select * From vEmployees;

Select * From vProductsByCategories;
Select * From vInventoriesByProductsByDates;
Select * From vInventoriesByEmployeesByDates;
Select * From vInventoriesByProductsByCategories;
Select * From vInventoriesByProductsByEmployees;
Select * From vInventoriesForChaiAndChangByEmployees;
Select * From vEmployeesByManager;
Select * From vInventoriesByProductsByCategoriesByEmployees;
/***************************************************************************************/