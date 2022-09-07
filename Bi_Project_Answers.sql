use 8it;
go


-- Exercise 1:
CREATE VIEW TotalPricePerOrder AS
SELECT OD.Order_ID AS OrderNumber, SUM(Me.Price) AS OrderPrice
FROM Members AS M JOIN Orders AS O ON M.ID = O.Member_ID
				  JOIN Order_Details AS OD ON O.ID = OD.Order_ID
				  JOIN Meals AS Me ON Me.ID = OD.Meal_ID
GROUP BY OD.Order_ID

go

-- Exercise 2:

ALTER TABLE Orders
ADD Total_Order int;
GO
UPDATE Orders
SET Total_Order = 0;
GO
UPDATE Orders
SET Total_Order = OrderPrice
FROM TotalPricePerOrder AS TPPO JOIN Orders AS O ON O.ID = TPPO.OrderNumber
GO

-- Exercise 3:

– Create Table

CREATE TABLE Customer_Data (ID int, 
							Full_Name VARCHAR(255), 
							Sex VARCHAR(1), 
							Email VARCHAR(255), 
							City VARCHAR(255), 
							Monthly_Budget INT, 
							TotalOrderByMonth INT, 
							MonthlyExpense INT, 
							OrderMonth INT,  
							OrderYear INT, 
							OrderAmount INT,
							MealAmount INT, 
							AteItPayout INT);

GO


– Create Procedure

CREATE PROCEDURE InsertIntoMonthlyCustomerData @OrderMonth int, @OrderYear int
AS
INSERT INTO Customer_Data ()
				SELECT  Mem.* , Ord.TotalOrderByMonth, Mem.Monthly_Budget - Ord.TotalOrderByMonth AS MonthlyExpense, Ord.OrderMonth, Ord.OrderYear, CO.OrderAmount, CO.MealAmount, AII.AteitPayout
				FROM(
								SELECT Member_ID, MONTH(Date) OrderMonth, YEAR(Date)OrderYear, SUM(Total_Order) TotalOrderByMonth
								FROM Orders
								GROUP BY Member_ID, MONTH(Date), YEAR(Date)
							) AS Ord JOIN(
								SELECT M.ID, M.First_Name + ' ' + M.Surname AS Full_Name, M.Sex, M.Email, C.City, M.Monthly_Budget
								FROM Members AS M JOIN Cities AS C ON M.City_ID = C.ID
							) AS Mem ON Ord.Member_ID = Mem.ID
							JOIN (
								SELECT Member_ID, MONTH(Date) OrderMonth, YEAR(Date) OrderYear, COUNT(DISTINCT Order_ID) OrderAmount, COUNT(Meal_ID) MealAmount
								FROM Order_Details AS OD JOIN Orders AS O ON OD.Order_ID = O.ID
								GROUP BY Member_ID, MONTH(Date), YEAR(Date)
							) AS CO ON Mem.ID = CO.Member_ID AND CO.OrderMonth = Ord.OrderMonth
							JOIN (
								SELECT Member_ID, MONTH(AIP.Date) OrderMonth, YEAR(AIP.Date) OrderYear, SUM(AteItPayout) AS AteitPayout
								FROM(SELECT Member_ID, O.Date, Income_Persentage * Total_Order AS AteItPayout
								FROM Orders AS O JOIN Restaurants AS R ON O.Restaurant_ID = R.ID
								) AS AIP
								GROUP BY Member_ID, MONTH(Date), YEAR(Date)
							) AS AII ON Ord.Member_ID = AII.Member_ID AND Ord.OrderMonth = AII.OrderMonth

				WHERE ord.OrderMonth = @OrderMonth AND Ord.OrderYear = @OrderYear
GO

– Example of January:
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 1, @OrderYear = 2020
GO
– Example of February
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 2, @OrderYear = 2020
GO
– Example of March
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 3, @OrderYear = 2020
GO
– Example of April
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 4, @OrderYear = 2020
GO
– Example of May
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 5, @OrderYear = 2020
GO
– Example of June
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 6, @OrderYear = 2020
GO
– Example of July
EXEC InsertIntoMonthlyCustomerData @OrderMonth = 7, @OrderYear = 2020
GO