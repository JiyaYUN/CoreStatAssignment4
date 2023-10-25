USE cis467_final_project;

SELECT * FROM categories; 

SELECT * FROM products;

SELECT * FROM suppliers;

SELECT * FROM customers;

SELECT * FROM employees;

SELECT * FROM employeeterritories;

SELECT * FROM territories;

SELECT * FROM region;

SELECT * FROM shippers;

SELECT * FROM orders;

SELECT * FROM order_details;

#get subtotal by order id
SELECT Order_Details.OrderID, ROUND(Sum((Order_Details.UnitPrice*Quantity*(1-Discount)/100)*100),2) AS Subtotal
FROM Order_Details
GROUP BY Order_Details.OrderID;

SELECT * FROM order_details WHERE orderID=10250;

SELECT *,Sum((Order_Details.UnitPrice*Quantity*(1-Discount)/100)*100) AS Subtotal
FROM order_details WHERE orderID=10250
GROUP BY Order_Details.OrderID;




#combine many tables
SELECT Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, Orders.ShipRegion, Orders.ShipPostalCode, 
	Orders.ShipCountry, Orders.CustomerID, Customers.CompanyName AS CustomerName, Customers.Address, Customers.City, 
	Customers.Region, Customers.PostalCode, Customers.Country, 
	CONCAT(FirstName, ' ', LastName) AS Salesperson, 
	Orders.OrderID, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Shippers.CompanyName As ShipperName, 
	Order_Details.ProductID, Products.ProductName, Order_Details.UnitPrice, Order_Details.Quantity, 
	Order_Details.Discount, 
	ROUND((Order_Details.UnitPrice*Quantity*(1-Discount)/100)*100,2) AS ExtendedPrice, Orders.Freight
FROM 	Shippers JOIN 
		(Products  JOIN 
			(
				(Employees  JOIN 
					(Customers  JOIN Orders ON Customers.CustomerID = Orders.CustomerID) 
				ON Employees.EmployeeID = Orders.EmployeeID) 
			 JOIN Order_Details ON Orders.OrderID = Order_Details.OrderID) 
		ON Products.ProductID = Order_Details.ProductID) 
	ON Shippers.ShipperID = Orders.ShipVia;



# Customer and Suppliers by City AS
SELECT City, CompanyName, ContactName, 'Customers' AS Relationship 
FROM Customers
UNION SELECT City, CompanyName, ContactName, 'Suppliers' AS Relationship
FROM Suppliers
ORDER BY City, CompanyName;

#List of products which are not discontinued
SELECT Products.*, Categories.CategoryName
FROM Categories JOIN Products ON Categories.CategoryID = Products.CategoryID
WHERE Products.Discontinued=0;

#Orders by customers
SELECT Orders.OrderID, Orders.CustomerID, Orders.EmployeeID, Orders.OrderDate, Orders.RequiredDate, 
	Orders.ShippedDate, Orders.ShipVia, Orders.Freight, Orders.ShipName, Orders.ShipAddress, Orders.ShipCity, 
	Orders.ShipRegion, Orders.ShipPostalCode, Orders.ShipCountry, 
	Customers.CompanyName, Customers.Address, Customers.City, Customers.Region, Customers.PostalCode, Customers.Country
FROM Customers JOIN Orders ON Customers.CustomerID = Orders.CustomerID;


# Products Above Average Price AS
SELECT Products.ProductName, Products.UnitPrice
FROM Products
WHERE Products.UnitPrice >(SELECT AVG(UnitPrice) From Products);

#fix the date data type
SELECT *, STR_TO_DATE(Orders.ShippedDate,"%m/%d/%Y") AS ShippedDateFixed 
FROM orders;

#Product Sales for 1997 
SELECT Categories.CategoryName, Products.ProductName, 
ROUND(Sum((Order_Details.UnitPrice*Quantity*(1-Discount)/100)*100),2) AS ProductSales, STR_TO_DATE(Orders.ShippedDate,"%m/%d/%Y")
AS ShippedDateFixed
FROM (Categories JOIN Products ON Categories.CategoryID = Products.CategoryID) 
	 JOIN (Orders 
		 JOIN Order_Details ON Orders.OrderID = Order_Details.OrderID) 
	ON Products.ProductID = Order_Details.ProductID
WHERE STR_TO_DATE(Orders.ShippedDate,"%m/%d/%Y") Between '1997-01-01' And '1997-12-31'
GROUP BY Categories.CategoryName, Products.ProductName;

DROP TABLE IF EXISTS CustomerOrder;

CREATE OR REPLACE VIEW CustomerOrder AS
SELECT
    orderQuery.OrderID, c.CustomerID, c.ContactName AS CustomerName, c.Country AS CustomerCountry, c.City AS CustomerCity,
    orderQuery.OrderDate, orderQuery.ShippedDate, orderQuery.ShipCountry, orderQuery.ShipCity, 
    shipperquery.ShipperID, shipperquery.ShipperName, order_detailsQuery.Quantity,
    order_detailsQuery.Discount, productQuery.ProductID, productQuery.ProductName,
    productQuery.SupplierID, productQuery.CategoryID,productQuery.UnitPrice, productQuery.UnitsInStock,
    productQuery.UnitsOnOrder,productQuery.ReorderLevel,productQuery.Discontinued,
    supplierQuery.CompanyName AS SupplierName,supplierQuery.Country AS SupplyCountry,supplierQuery.City AS SupplyCity,
    categoryQuery.CategoryName
FROM customers c
JOIN (
    SELECT OrderID, CustomerID, OrderDate, ShippedDate, ShipCity, ShipCountry, ShipVia
    FROM orders
    GROUP BY OrderID
) AS orderQuery ON orderQuery.CustomerID = c.CustomerID
JOIN (
    SELECT ShipperID, CompanyName AS ShipperName
    FROM shippers
) AS shipperquery ON shipperquery.ShipperID = orderQuery.ShipVia
JOIN (
    SELECT OrderID, Quantity, Discount, ProductID
    FROM order_details
    GROUP BY OrderID
) AS order_detailsQuery ON order_detailsQuery.OrderID = orderQuery.OrderID
JOIN (
    SELECT ProductID, ProductName, SupplierID, CategoryID, UnitPrice, UnitsInStock, UnitsOnOrder, ReorderLevel, Discontinued
    FROM products
) AS productQuery ON productQuery.ProductID = order_detailsQuery.ProductID
JOIN (
    SELECT SupplierID, CompanyName, ContactName, Country, City
    FROM suppliers
) AS supplierQuery ON supplierQuery.SupplierID = productQuery.SupplierID
JOIN (
    SELECT CategoryID, CategoryName
    FROM categories
) AS categoryQuery ON categoryQuery.CategoryID = productQuery.CategoryID;

SELECT * FROM CustomerOrder;

