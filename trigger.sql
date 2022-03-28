CREATE TRIGGER UpdateUserDiscounts ON OrderDetails AFTER INSERT
AS
BEGIN
  SET NOCOUNT ON

  DECLARE @CustomerID int
  DECLARE @DiscountFTID int
  DECLARE @DiscountSTID int
  DECLARE @LastDiscountDate date
  DECLARE @Z1 decimal(10,2)
  DECLARE @K1 decimal(10,2)
  DECLARE @K2 decimal(10,2)


	SET @CustomerID = 
    (SELECT O.CustomerID FROM Inserted
    INNER JOIN Orders AS O ON Inserted.OrderID = O.OrderID)  
	
	IF EXISTS
	(
		SELECT CustomerID FROM CustomerIndividuals WHERE CustomerID=@CustomerID
	)
	BEGIN
	
		IF NOT EXISTS 
			(
				SELECT DiscountID FROM CustomerDiscountFT WHERE CustomerID=@CustomerID
			)
			BEGIN

				SET @DiscountFTID=
				(
					SELECT DiscountID FROM Discounts 
					WHERE EndDate IS NULL AND DiscountType=1 
				)
				SET @Z1=(
					SELECT DSD.Value FROM DiscountSetDetails AS DSD 
					INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
					WHERE DSD.DiscountID=@DiscountFTID AND SetName='Z1' 
					)
				SET @K1=(
					SELECT DSD.Value FROM DiscountSetDetails AS DSD 
					INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
					WHERE DSD.DiscountID=@DiscountFTID AND SetName='K1' 
					)

				IF
				(
					(SELECT COUNT(*) FROM Orders AS O
					WHERE O.CustomerID=@CustomerID AND 
					(SELECT SUM(DishPrice*Quantity) FROM  OrderDetails WHERE OrderID=O.OrderID GROUP BY OrderID)>@Z1
					GROUP BY O.CustomerID)
					>=@Z1
				)
				BEGIN
					INSERT INTO CustomerDiscountFT(CustomerID,DiscountID)
					VALUES (@CustomerID,@DiscountFTID)
				END
			END

			UPDATE CustomerDiscountsST SET UseDate=GETDATE() WHERE UseDate IS NULL AND EXISTS 
			(SELECT DSD.DiscountID FROM  DiscountSetDetails AS DSD 
			INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
			WHERE DSD.DiscountID=DiscountID AND SetName='D1' AND DATEDIFF(DAY,ReceivedDate,GETDATE())>Value
			)

			IF NOT EXISTS 
			(
				SELECT DiscountSTID FROM CustomerDiscountsST WHERE CustomerID=@CustomerID AND UseDate IS NULL 
			)
			BEGIN
				
				SET @LastDiscountDate=(
					SELECT TOP 1 UseDate FROM CustomerDiscountsST WHERE CustomerID=2 AND UseDate IS NOT NULL 
					ORDER BY UseDate DESC
				)
				SET @DiscountSTID=
				(
					SELECT DiscountID FROM Discounts 
					WHERE EndDate IS NULL AND DiscountType=2
				)
				SET @K2=(
					SELECT DSD.Value FROM DiscountSetDetails AS DSD 
					INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
					WHERE DSD.DiscountID=@DiscountFTID AND SetName='K2' 
					)

					

				IF
				(

					(SELECT SUM(Sumy.suma) FROM (
					SELECT (SELECT SUM(OD.DishPrice*OD.Quantity) FROM OrderDetails AS OD WHERE OD.OrderID=O.OrderID GROUP BY OD.OrderID) as suma,O.CustomerID as Customer FROM Orders AS O
					WHERE O.CustomerID=2 AND O.OrderDate>ISNULL('2021-04-04','1980-01-01')
					GROUP BY O.CustomerID,O.OrderID) as Sumy
					GROUP BY Sumy.Customer)>@K2

				)
				BEGIN
					INSERT INTO CustomerDiscountsST(CustomerID,DiscountID)
					VALUES (@CustomerID,@DiscountSTID)
				END
			END
	END
  
END
GO

ALTER TABLE DishesHistory ENABLE TRIGGER DishCountCheck