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
    orderQuery.OrderDate, orderQuery.ShippedDate, orderQuery.ShipCountry, orderQuery.ShipCity, orderQuery.Freight, shipperquery.ShipperID, shipperquery.ShipperName, 
    order_detailsQuery.Quantity, order_detailsQuery.Discount, productQuery.ProductID, productQuery.ProductName,
    productQuery.CategoryID, productQuery.UnitPrice, productQuery.UnitsInStock,
    productQuery.UnitsOnOrder,productQuery.ReorderLevel,productQuery.Discontinued,
    categoryQuery.CategoryName
FROM customers c
JOIN (
    SELECT OrderID, CustomerID, OrderDate, ShippedDate, ShipCity, ShipCountry, ShipVia, Freight
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
    SELECT CategoryID, CategoryName
    FROM categories
) AS categoryQuery ON categoryQuery.CategoryID = productQuery.CategoryID;

SELECT * FROM CustomerOrder;

-- find the countries of top 10 sales
SELECT CustomerCountry, ROUND(Sum((UnitPrice*Quantity*(1-Discount)/100)*100),2) AS Sales
FROM customerorder
GROUP BY CustomerCountry 
ORDER BY Sales DESC LIMIT 10;

-- find the number of orders that were shipped over a one-week period and group the results by three expressions
SELECT ShipperID, ShipperName, COUNT(OrderID) AS NumberOfOrders
FROM (
    SELECT 
        OrderID,
        ShipperID,
        ShipperName
    FROM CustomerOrder
    WHERE DATEDIFF(STR_TO_DATE(ShippedDate, '%c/%e/%Y'), STR_TO_DATE(OrderDate, '%c/%e/%Y')) > 7
) AS OrderDateDifference
GROUP BY ShipperID
ORDER BY NumberOfOrders DESC;

--  find the popular category with more orders
SELECT CategoryName, COUNT(ProductName) AS NumberOfOrder
FROM customerorder
GROUP BY CategoryName
ORDER BY NumberOfOrder DESC;

-- find the number of orders in each category with a discount
SELECT CategoryName, SUM(CASE WHEN Discount = 0 THEN 0 ELSE 1 END) AS CountOfOrdersWithDiscount
FROM CustomerOrder
GROUP BY CategoryName;

-- find categories with a higher number of inventory and assign them to classes
SELECT CategoryName, ProductID, ProductName, Inventory,
NTILE(5) OVER (ORDER BY Inventory) AS InventoryClass
FROM(
SELECT CategoryName, ProductID, ProductName, SUM(UnitsInStock + UnitsOnOrder) AS Inventory
FROM CustomerOrder
GROUP BY CategoryName
) AS InventoryQuery
ORDER BY Inventory DESC;

-- find customer whose order is closer to current date and more order value
SELECT CustomerID, CustomerName, MAX(CURDATE() - STR_TO_DATE(ShippedDate, '%c/%e/%Y')) AS RecentOrderAge,
MAX(UnitPrice * Quantity * (1 - Discount)) AS MaxOrderValue
FROM customerorder
GROUP BY CustomerID
ORDER BY RecentOrderAge DESC, MaxOrderValue DESC;

-- find the orders where the customer's city matches the shipper's city
SELECT OrderID, ProductName, CategoryName, ROUND((UnitPrice * Quantity * (1 - Discount) - Freight), 2) AS TotalPayment
FROM customerorder
WHERE CustomerCity = ShipCity
ORDER BY TotalPayment DESC;

--  find the category with the top total payment
SELECT CategoryName, ROUND(SUM((UnitPrice * Quantity * (1 - Discount) - Freight)),2) AS TotalPayment
FROM customerorder
GROUP BY CategoryName
ORDER BY TotalPayment DESC;




