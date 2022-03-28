CREATE PROCEDURE AddIndividualCustomer
	@FirstName varchar(50),
	@LastName varchar(50),
	@Phone nchar(9)
AS 
BEGIN
	BEGIN TRY 

	
	INSERT INTO Customers(Phone)
	VALUES (@Phone)
	DECLARE @CustomerID int;
	SELECT @CustomerID=SCOPE_IDENTITY();
	INSERT INTO CustomerIndividuals(CustomerID,FirstName,LastName)
	VALUES (@CustomerID,@FirstName,@LastName)


	END TRY 
	BEGIN CATCH
	DELETE FROM Customers
		WHERE CustomerID=@CustomerID
	DELETE FROM CustomerIndividuals
		WHERE CustomerID=@CustomerID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new Individual Customer. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO
	

CREATE PROCEDURE AddFirmCustomer
	@CompanyName varchar(50),
	@NIP nchar(10),
	@Address varchar(50),
	@PostalCode varchar(50),
	@Phone nchar(9),
	@CityName varchar(50)
AS 
BEGIN
	BEGIN TRY 
	
	IF NOT EXISTS
	(
	SELECT CityID FROM Cities WHERE CityName=@CityName
	)
	BEGIN
		;THROW 52000, 'City does not exist.',1
	END

	DECLARE @CityID int;
	SET @CityID = (
	SELECT CityID FROM Cities WHERE CityName=@CityName
	);

	

	INSERT INTO Customers(Phone)
	VALUES (@Phone)

	DECLARE @CustomerID int;
	SELECT @CustomerID=SCOPE_IDENTITY();

	INSERT INTO CustomerFirms(CustomerID,CityID,PostalCode,Address,CompanyName,NIP)
	VALUES (@CustomerID,@CityID,@PostalCode,@Address,@CompanyName,@NIP)


	END TRY 
	BEGIN CATCH
	DELETE FROM Customers
		WHERE CustomerID=@CustomerID
	DELETE FROM CustomerFirms
		WHERE CustomerID=@CustomerID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new Firm Customer. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO
	

CREATE PROCEDURE AddFirmEmployee
	@FirstName varchar(50),
	@LastName varchar(50),
	@NIP nchar(10),
	@Phone nchar(9)
AS 
BEGIN
	BEGIN TRY 
	DECLARE @CustomerID int;
	DECLARE @FirmID int;
	IF NOT EXISTS
	(
		SELECT * FROM Customers WHERE Phone=@Phone
	)
	BEGIN
		INSERT INTO Customers(Phone)
		VALUES (@Phone)
		SELECT @CustomerID=SCOPE_IDENTITY()
		INSERT INTO CustomerIndividuals(CustomerID,FirstName,LastName)
		VALUES (@CustomerID,@FirstName,@LastName)
	END
	ELSE
	BEGIN
		SET @CustomerID = (
			SELECT CustomerID FROM Customers WHERE Phone=@Phone
			);
	END

	SET @FirmID = (
			SELECT CustomerID FROM CustomerFirms WHERE NIP=@NIP
			);

	IF NOT EXISTS
			(
			SELECT CustomerID FROM CustomerFirms WHERE NIP=@NIP
			)
			BEGIN
				;THROW 52000, 'Firm does not exist.',1
			END

	INSERT INTO CustomerFirmsEmployees(CustomerID,FirmID)
	VALUES (@CustomerID,@FirmID)

	END TRY 
	BEGIN CATCH
	IF NOT EXISTS
	(
		SELECT * FROM Customers WHERE Phone=@Phone
	)
	BEGIN
		DELETE FROM Customers
			WHERE CustomerID=@CustomerID
		DELETE FROM CustomerIndividuals
			WHERE CustomerID=@CustomerID
	END
	DECLARE @errorMsg nvarchar(2048)='Cannot add new Firm Employee. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO
	


CREATE PROCEDURE AddRestaurantEmployee
	@FirstName varchar(50),
	@LastName varchar(50),
	@ManagerID int = null,
	@Phone nchar(9),
	@CityName varchar(50),
	@PostalCode varchar(50),
	@Address varchar(50)
AS 
BEGIN
	BEGIN TRY 
		DECLARE @CityID int;

		IF NOT EXISTS
			(
			SELECT CityID FROM Cities WHERE CityName=@CityName
			)
			BEGIN
				;THROW 52000, 'City does not exist.',1
			END

		SET @CityID = (
		SELECT CityID FROM Cities WHERE CityName=@CityName
		);
		INSERT INTO Employees(FirstName,LastName,ManagerID,Phone,CityID,PostalCode,Address)
		VALUES (@FirstName,@LastName,@ManagerID,@Phone,@CityID,@PostalCode,@Address)
		DECLARE  @EmployeeID int
		SELECT @EmployeeID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Employees
		WHERE EmployeeID=@EmployeeID

	DECLARE @errorMsg nvarchar(2048)='Cannot add new Firm Employee. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO
	


CREATE PROCEDURE AddPaymentType
	@PaymentName varchar(50)
AS 
BEGIN
	BEGIN TRY 
		INSERT INTO PaymentType(PaymentName)
		VALUES (@PaymentName)
		DECLARE  @PaymentTypeID int
		SELECT @PaymentTypeID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM PaymentType
		WHERE PaymentTypeID=@PaymentTypeID

	DECLARE @errorMsg nvarchar(2048)='Cannot add new Payment Type. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO
	

CREATE PROCEDURE AddDish
	@DishName varchar(50),
	@Description varchar(500)=NULL,
	@CategoryName varchar(50),
	@MinStockValue int=NULL,
	@BasicDishPrice decimal(10,2),
	@StartUnits int

AS 
BEGIN
	BEGIN TRY 
		IF NOT EXISTS
			(
			SELECT CategoryID FROM Categories WHERE CategoryName=@CategoryName
			)
			BEGIN
				;THROW 52000, 'Category does not exist.',1
			END

		IF (@StartUnits<@MinStockValue)
		BEGIN
				;THROW 52000, 'Units on start has to be greater than minimal value',1
			END

		IF 
		(
		@BasicDishPrice<=0
		)
		BEGIN
			;THROW 52000, 'Basic dish price has to be greater than 0.',1
		END

		DECLARE @CategoryID int
		SET @CategoryID = (
		SELECT CategoryID FROM Categories WHERE CategoryName=@CategoryName
		);
		

		INSERT INTO Dishes(DishName,Description,CategoryID,MinStockValue,BasicDishPrice)
		VALUES (@DishName,@Description,@CategoryID,@MinStockValue,@BasicDishPrice)
		DECLARE  @DishID int
		SELECT @DishID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Dishes
		WHERE DishID=@DishID

	DECLARE @errorMsg nvarchar(2048)='Cannot add new Dish. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO



CREATE PROCEDURE AddCategory
	@CategoryName varchar(50),
	@Description varchar(500)=NULL
AS 
BEGIN
	BEGIN TRY 
		INSERT INTO Categories(CategoryName,Description)
		VALUES (@Categoryname,@Description)
		DECLARE  @CategoryID int
		SELECT @CategoryID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Categories
		WHERE CategoryID=@CategoryID

	DECLARE @errorMsg nvarchar(2048)='Cannot add new Category. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddCity
	@CityName varchar(50)
AS 
BEGIN
	BEGIN TRY 
		
		INSERT INTO Cities(CityName)
		VALUES (@CityName)
		DECLARE  @CityID int
		SELECT @CityID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Cities
		WHERE CityID=@CityID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new City. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddDishToMenu
	@DishName varchar(50),
	@DishPrice decimal(10, 2),
	@UnitsInStock int
AS 
BEGIN
	BEGIN TRY 
	DECLARE @DishID int;
		IF NOT EXISTS
		(
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		)
		BEGIN
			;THROW 52000, 'Dish does not exist.',1
		END

		SET @DishID = (
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		);

		IF EXISTS
		(
			SELECT DishID FROM DishesHistory WHERE DishID=@DishID AND OutMenuDate IS NULL
		)
		BEGIN
			;THROW 52000, 'Dish is already in menu.',1
		END

		IF NOT EXISTS
		(
			SELECT DishID FROM Dishes WHERE DishName=@DishName and @UnitsInStock>=MinStockValue
		)
		BEGIN
			;THROW 52000, 'There is not enough portions of this dish in stock.',1
		END

		INSERT INTO DishesHistory(DishPrice,InMenuDate,OutMenuDate,UnitsInStock,DishID)
		VALUES (@DishPrice,GETDATE(),NULL,@UnitsInStock,@DishID)
		DECLARE  @DishesHistoryID int
		SELECT @DishesHistoryID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM DishesHistory
		WHERE DishesHistoryID=@DishesHistoryID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new dish to Menu. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO


CREATE PROCEDURE RemoveDishFromMenu
	@DishName varchar(50)
AS 
BEGIN
	BEGIN TRY 
	DECLARE @DishID int;
	DECLARE @DishesHistoryID int;
		IF NOT EXISTS
		(
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		)
		BEGIN
			;THROW 52000, 'Dish does not exist.',1
		END

		SET @DishID = (
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		);
		
		IF NOT EXISTS
		(
			SELECT DishID FROM DishesHistory WHERE DishID=@DishID AND OutMenuDate IS NULL
		)
		BEGIN
			;THROW 52000, 'This dish is not in menu.',1
		END

		SET @DishesHistoryID = (
			SELECT DishesHistoryID FROM DishesHistory WHERE DishID=@DishID AND OutMenuDate IS NULL
		);

		UPDATE DishesHistory SET OutMenuDate=GETDATE() WHERE DishesHistoryID=@DishesHistoryID
	END TRY 
	BEGIN CATCH
	DECLARE @errorMsg nvarchar(2048)='Cannot delete dish from Menu. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE ChangeUnitsInStockValueForDish
	@DishName varchar(50),
	@UnitsInStock int
AS 
BEGIN
	BEGIN TRY 
	DECLARE @DishID int;
	DECLARE @DishesHistoryID int;

		IF NOT EXISTS
		(
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		)
		BEGIN
			;THROW 52000, 'Dish does not exist.',1
		END

		SET @DishID = (
			SELECT DishID FROM Dishes WHERE DishName=@DishName
		);

		IF NOT EXISTS
		(
			SELECT DishesHistoryID FROM DishesHistory WHERE DishID=@DishID AND OutMenuDate IS NULL
		)
		BEGIN
			;THROW 52000, 'Dish is not in Menu.',1
		END

		SET @DishesHistoryID = (
			SELECT DishesHistoryID FROM DishesHistory WHERE DishID=@DishID AND OutMenuDate IS NULL
		);


		IF NOT EXISTS
		(
			SELECT DishID FROM Dishes WHERE DishName=@DishName AND @UnitsInStock>=MinStockValue
		)
		BEGIN
			;THROW 52000, 'New value is smaller than minimal value for this dish.',1
		END

		UPDATE DishesHistory SET UnitsInStock=@UnitsInStock WHERE DishesHistoryID=@DishesHistoryID

	END TRY 
	BEGIN CATCH
	DECLARE @errorMsg nvarchar(2048)='Cannot change units in stock value. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO



CREATE PROCEDURE AddOrder
	@Phone nchar(9),
	@EmployeeID int=NULL,
	@PaymentName varchar(50),
	@ReceiveDate datetime
AS 
BEGIN
	BEGIN TRY 
		DECLARE @OrderID int;
		DECLARE @CustomerID int;
		DECLARE @PaymentTypeID int;

		IF NOT EXISTS
		(
			SELECT CustomerID FROM Customers WHERE Phone=@Phone
		)
		BEGIN
			;THROW 52000, 'Customer does not exist.',1
		END

		SET @CustomerID = (
			SELECT CustomerID FROM Customers WHERE Phone=@Phone
		);


		IF NOT EXISTS
		(
			SELECT PaymentTypeID FROM PaymentType WHERE PaymentName=@PaymentName
		)
		BEGIN
			;THROW 52000, 'Payment type does not exist.',1
		END

		SET @PaymentTypeID = (
			SELECT PaymentTypeID FROM PaymentType WHERE PaymentName=@PaymentName
		);

		IF
		(
		@EmployeeID IS NOT NULL
		)
		BEGIN
			IF NOT EXISTS 
			(
				SELECT EmployeeID FROM Employees WHERE EmployeeID=@EmployeeID
			)
			BEGIN
				;THROW 52000, 'Employee does not exist.',1
			END
		END

		IF 
		(
			DATEDIFF(DAY,GETDATE(),@ReceiveDate)<0
		)
		BEGIN
			;THROW 52000, 'Receive date can not be before order date',1
		END

		INSERT INTO Orders(CustomerID,EmployeeID,OrderDate,ReceiveDate,PaymentTypeID)
		VALUES (@CustomerID,@EmployeeID,GETDATE(),@ReceiveDate,@PaymentTypeID)
		SELECT @OrderID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Orders
		WHERE OrderID=@OrderID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new order. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddDishToOrder
	@OrderID int,
	@DishesHistoryID int,
	@Quantity int,
	@CustomerID int
AS 
BEGIN
	BEGIN TRY 
		DECLARE @Discount int;
		DECLARE @ReceiveDate date;
		DECLARE @OrderDate date=GETDATE();
		DECLARE @BasicDishPrice decimal(10, 2);
		DECLARE @UnitsInStock int;
		DECLARE @DiscountIDFT int=NULL;
		DECLARE @DiscountIDST int=NULL;


		IF NOT EXISTS
		(
			(SELECT CustomerID FROM Customers WHERE CustomerID=@CustomerID) 
		)
		BEGIN
			;THROW 52000, 'Customer does not exist.',1
		END

		IF NOT EXISTS
		(
			SELECT UnitsInStock FROM DishesHistory WHERE DishesHistoryID=@DishesHistoryID AND OutMenuDate IS NULL
		)
		BEGIN
			;THROW 52000, 'Dish does not exist in menu.',1
		END

		IF NOT EXISTS
		(
			(SELECT OrderID FROM Orders WHERE OrderID=@OrderID) 
		)
		BEGIN
			;THROW 52000, 'Order does not exist.',1
		END

		SET @UnitsInStock = (
			SELECT UnitsInStock FROM DishesHistory WHERE DishesHistoryID=@DishesHistoryID AND OutMenuDate IS NULL
		);

		SET @ReceiveDate = (
			(SELECT ReceiveDate FROM Orders WHERE OrderID=@OrderID) 
		);


		SET @BasicDishPrice=
		(
		SELECT DishPrice FROM DishesHistory WHERE DishesHistoryID=@DishesHistoryID AND OutMenuDate IS NULL
		)
		IF
		(
		@UnitsInStock<@Quantity
		)
		BEGIN
			;THROW 52000, 'There is not enough dish in stock.',1
		END
		


		IF EXISTS
		(
			SELECT DishesHistoryID FROM DishesHistory AS DH
			INNER JOIN Dishes AS D ON DH.DishID=D.DishID
			INNER JOIN Categories AS C ON D.CategoryID=C.CategoryID
			WHERE DH.DishesHistoryID=@DishesHistoryID AND C.CategoryName='Owoce morza'
		)
		BEGIN
			IF NOT
			(
				DATEPART(WEEKDAY, @ReceiveDate) between 4 and 6
			)
			BEGIN
			;THROW 52000, 'Seafood can be order only between thursday and saturday.',1
			END

			IF
			(
				DATEDIFF(WEEK,@OrderDate,@ReceiveDate)=0
			)
			AND
			(
				DATEPART(WEEKDAY, @OrderDate) not like 1
			)
			BEGIN
			;THROW 52000, 'Seafood must be ordered before tuesday.',1
			END
		END

		IF EXISTS
		(
			SELECT CustomerID FROM CustomerIndividuals WHERE CustomerID=@CustomerID
		)
		BEGIN
			
			IF EXISTS
			(
				SELECT DiscountID FROM CustomerDiscountFT WHERE CustomerID=@CustomerID
			)
			BEGIN
				SET @DiscountIDFT=(
					SELECT DiscountID FROM CustomerDiscountFT WHERE CustomerID=@CustomerID
				);
			END

			IF EXISTS
			(
				SELECT DiscountID FROM CustomerDiscountsST WHERE CustomerID=@CustomerID AND UseDate IS NULL
			)
			BEGIN
				SET @DiscountIDST=(
					SELECT DiscountID FROM CustomerDiscountsST WHERE CustomerID=@CustomerID AND UseDate IS NULL
				);
			END

			IF
			(
				(SELECT Value FROM DiscountSetDetails AS DSD
				INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
				WHERE DS.SetName='R' AND DSD.DiscountID=@DiscountIDFT)
				>=
				(SELECT Value FROM DiscountSetDetails AS DSD
				INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
				WHERE DS.SetName='R' AND DSD.DiscountID=@DiscountIDST)
			)
			BEGIN
				SET @Discount=
				(SELECT Value FROM DiscountSetDetails AS DSD
				INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
				WHERE DS.SetName='R' AND DSD.DiscountID=@DiscountIDFT)
			END
			ELSE
			BEGIN
				SET @Discount=
				(SELECT Value FROM DiscountSetDetails AS DSD
				INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
				WHERE DS.SetName='R' AND DSD.DiscountID=@DiscountIDST)
			END
		END
		ELSE
		BEGIN
			SET @Discount=0
		END

		UPDATE DishesHistory  SET UnitsInStock=@UnitsInStock-@Quantity  WHERE DishesHistoryID=@DishesHistoryID
		INSERT INTO OrderDetails(OrderID,DishesHistoryID,Quantity,DishPrice)
		VALUES (@OrderID,@DishesHistoryID,@Quantity,(@BasicDishPrice*(100-@Discount))/100)

	END TRY 
	BEGIN CATCH
	DELETE FROM OrderDetails
		WHERE OrderID=@OrderID
	DECLARE @errorMsg nvarchar(2048)='Cannot add dish to order. Order is removed. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO





CREATE PROCEDURE AddReservationForIndividual
	@CustomerID int,
	@OrderID int,
	@PeopleCount int,
	@ReservationDate date
AS 
BEGIN
	BEGIN TRY 

		IF NOT EXISTS
		(
			(SELECT OrderID FROM Orders WHERE OrderID=@OrderID and CustomerID=@CustomerID) 
		)
		BEGIN
			;THROW 52000, 'Order does not exist.',1
		END

		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerIndividuals WHERE CustomerID=@CustomerID) 
		)
		BEGIN
			;THROW 52000, 'Customer does not exist.',1
		END

		IF
		(
		DATEDIFF(DAY,GETDATE(),@ReservationDate)<=0
		)
		BEGIN
			;THROW 52000, 'Invalid reservaton date.',1
		END

		IF
		(
			(SELECT SUM(DishPrice*Quantity) FROM OrderDetails AS OD WHERE OD.OrderID=@OrderID GROUP BY OD.OrderID)
			<
			(SELECT WZValue FROM ReservationRequirements)
		) 
		BEGIN
			;THROW 52000, 'Value of order is to small.',1
		END

		IF
		(
		(SELECT COUNT(*) FROM Orders WHERE OrderID=@OrderID GROUP BY OrderID)
			<
		(SELECT WKValue FROM ReservationRequirements)
		)
		BEGIN
			;THROW 52000, 'Number of orders is to small.',1
		END
	
		

		INSERT INTO Reservations(ReservationDate)
		VALUES (@ReservationDate)
		DECLARE  @ReservationID int
		SELECT @ReservationID=SCOPE_IDENTITY()

		INSERT INTO ReservationsIndividuals(ReservationID,CustomerID,OrderID,PeopleCount)
		VALUES (@ReservationID,@CustomerID,@OrderID,@PeopleCount)

	END TRY 
	BEGIN CATCH
	DELETE FROM ReservationsIndividuals
		WHERE ReservationID=@ReservationID
	DELETE FROM Reservations
		WHERE ReservationID=@ReservationID
	DECLARE @errorMsg nvarchar(2048)='Cannot add reservation. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddReservationForFirm
	@FirmID int,
	@ReservationDate date
AS 
BEGIN
	BEGIN TRY 


		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerFirms WHERE CustomerID=@FirmID) 
		)
		BEGIN
			;THROW 52000, 'Firm does not exist.',1
		END

		IF
		(
		DATEDIFF(DAY,GETDATE(),@ReservationDate)<=0
		)
		BEGIN
			;THROW 52000, 'Invalid reservaton date.',1
		END

		INSERT INTO Reservations(ReservationDate)
		VALUES (@ReservationDate)
		DECLARE  @ReservationID int
		SELECT @ReservationID=SCOPE_IDENTITY()

		INSERT INTO ReservationsFirms(ReservationID,FirmID)
		VALUES (@ReservationID,@FirmID)

	END TRY 
	BEGIN CATCH

	DELETE FROM Reservations
		WHERE ReservationID=@ReservationID
	DELETE FROM ReservationsFirms
		WHERE ReservationID=@ReservationID
	DECLARE @errorMsg nvarchar(2048)='Cannot add reservation. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddReservationForFirmAnonymous
	@FirmID int,
	@ReservationID int,
	@PeopleCount int
AS 
BEGIN
	BEGIN TRY 

		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerFirms WHERE CustomerID=@FirmID) 
		)
		BEGIN
			;THROW 52000, 'Firm does not exist.',1
		END

		IF NOT EXISTS
		(
			(SELECT FirmID FROM ReservationsFirms WHERE FirmID=@FirmID) 
		)
		BEGIN
			;THROW 52000, 'Reservation does not exist.',1
		END


		INSERT INTO ReservationsFirmsDetails(ReservationID,PeopleCount)
		VALUES (@ReservationID,@PeopleCount)

	END TRY 
	BEGIN CATCH

	DELETE FROM ReservationsFirmsDetails
		WHERE ReservationID=@ReservationID
	DECLARE @errorMsg nvarchar(2048)='Cannot add reservation. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO


CREATE PROCEDURE AddReservationForFirmEmployee
	@FirmID int,
	@PeopleCount int,
	@Phone nchar(9),
	@ReservationID int
AS 
BEGIN
	BEGIN TRY 
		DECLARE @CustomerID int;


		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerFirms WHERE CustomerID=@FirmID) 
		)
		BEGIN
			;THROW 52000, 'Firm does not exist.',1
		END

		IF NOT EXISTS
		(
			(SELECT CustomerID FROM Customers WHERE Phone=@Phone) 
		)
		BEGIN
			;THROW 52000, 'Firm employee does not exist.',1
		END

		SET @CustomerID=
		(
			SELECT CustomerID FROM Customers WHERE Phone=@Phone
		);

		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerIndividuals WHERE CustomerID=@CustomerID) 
		)
		BEGIN
			;THROW 52000, 'Firm employee does not exist.',1
		END

		IF NOT EXISTS
		(
			(SELECT CustomerID FROM CustomerFirmsEmployees WHERE CustomerID=@CustomerID and FirmID=@FirmID) 
		)
		BEGIN
			;THROW 52000, 'This person is not employee of this firm',1
		END



		INSERT INTO ReservationsFirmsEmployees(ReservationID,EmployeeID,PeopleCount)
		VALUES (@ReservationID,@CustomerID,@PeopleCount)


	END TRY 
	BEGIN CATCH


	DELETE FROM ReservationsFirmsEmployees
		WHERE ReservationID=@ReservationID and EmployeeID=@CustomerID
	DECLARE @errorMsg nvarchar(2048)='Cannot add reservation. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO


CREATE PROCEDURE ConfirmReservation
	@EmployeeID int,
	@ReservationID int
AS 
BEGIN
	BEGIN TRY 
		DECLARE @PeopleCount int;
		DECLARE @ReservationDate date;
		DECLARE @TableID int;

		IF NOT EXISTS
		(
			(SELECT ReservationID FROM Reservations WHERE ReservationID=@ReservationID) 
		)
		BEGIN
			;THROW 52000, 'Reservation does not exist.',1
		END

		SET @ReservationDate=
		(
			(SELECT ReservationDate FROM Reservations WHERE ReservationID=@ReservationID) 
		);


		IF EXISTS
		(
			(SELECT ReservationID FROM ReservationsIndividuals WHERE ReservationID=@ReservationID) 
		)
		BEGIN
			SET @PeopleCount =
			(
				(SELECT PeopleCount FROM ReservationsIndividuals WHERE ReservationID=@ReservationID)
			)

			IF NOT EXISTS
			(
				SELECT * FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount
			)
			BEGIN
				;THROW 52000, 'There is not free table.',1
			END

			SET @TableID=
			(
				SELECT TOP 1 TableID FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount order by Places
			)
			UPDATE ReservationsIndividuals SET TableID=@TableID WHERE ReservationID=@ReservationID

		END

		IF EXISTS
		(
			(SELECT ReservationID FROM ReservationsFirms WHERE ReservationID=@ReservationID) 
		)
		BEGIN
			

			DECLARE @RFDIDCursor CURSOR;
			DECLARE @RFDID int;
			SET @RFDIDCursor = CURSOR FOR (SELECT RFDID FROM ReservationsFirmsDetails WHERE ReservationID=@ReservationID)

			BEGIN
				OPEN @RFDIDCursor
				FETCH NEXT FROM @RFDIDCursor
				INTO @RFDID
				WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @PeopleCount =
					(
						(SELECT PeopleCount FROM ReservationsFirmsDetails WHERE RFDID=@RFDID)
					)
					IF NOT EXISTS
					(
						SELECT * FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount
					)
					BEGIN
						;THROW 52000, 'There is not free table.',1
					END

					SET @TableID=
					(
						SELECT TOP 1 TableID FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount order by Places
					)

					UPDATE ReservationsFirmsDetails SET TableID=@TableID WHERE RFDID=@RFDID

					FETCH NEXT FROM @RFDIDCursor
					INTO @RFDID

				END
				CLOSE @RFDIDCursor
				DEALLOCATE @RFDIDCursor
			END

			DECLARE @FirmEmployeeIDCursor CURSOR;
			DECLARE @FirmEmployeeID int;
			SET @FirmEmployeeIDCursor = CURSOR FOR (SELECT EmployeeID FROM ReservationsFirmsEmployees WHERE ReservationID=@ReservationID)

			BEGIN
				OPEN @FirmEmployeeIDCursor
				FETCH NEXT FROM @FirmEmployeeIDCursor
				INTO @FirmEmployeeID
				WHILE @@FETCH_STATUS = 0
				BEGIN

					SET @PeopleCount =
					(
						(SELECT PeopleCount FROM ReservationsFirmsEmployees WHERE ReservationID=@ReservationID and EmployeeID=@FirmEmployeeID)
					)

					IF NOT EXISTS
					(
						SELECT * FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount
					)
					BEGIN
						;THROW 52000, 'There is not free table.',1
					END

					SET @TableID=
					(
						SELECT TOP 1 TableID FROM FreeTables(@ReservationDate) WHERE Places>=@PeopleCount order by Places
					)

					UPDATE ReservationsFirmsEmployees SET TableID=@TableID WHERE ReservationID=@ReservationID and EmployeeID=@FirmEmployeeID

					FETCH NEXT FROM @FirmEmployeeIDCursor
					INTO @FirmEmployeeID

				END
				CLOSE @FirmEmployeeIDCursor
				DEALLOCATE @FirmEmployeeIDCursor
			END
		END


	UPDATE Reservations SET EmployeeID=@EmployeeID  WHERE ReservationID=@ReservationID
	END TRY 
	BEGIN CATCH

			IF EXISTS
			(
				(SELECT ReservationID FROM ReservationsIndividuals WHERE ReservationID=@ReservationID) 
			)
			BEGIN
				UPDATE ReservationsIndividuals SET TableID=NULL WHERE ReservationID=@ReservationID
			END

			SET @RFDIDCursor = CURSOR FOR (SELECT RFDID FROM ReservationsFirmsDetails WHERE ReservationID=@ReservationID)
			BEGIN
				OPEN @FirmEmployeeIDCursor
				FETCH NEXT FROM @FirmEmployeeIDCursor
				INTO @FirmEmployeeID
				WHILE @@FETCH_STATUS = 0
				BEGIN

					UPDATE ReservationsFirmsEmployees SET TableID=NULL WHERE ReservationID=@ReservationID and EmployeeID=@FirmEmployeeID

					FETCH NEXT FROM @FirmEmployeeIDCursor
					INTO @FirmEmployeeID

				END
				CLOSE @FirmEmployeeIDCursor
				DEALLOCATE @FirmEmployeeIDCursor
			END

			SET @FirmEmployeeIDCursor = CURSOR FOR (SELECT EmployeeID FROM ReservationsFirmsEmployees WHERE ReservationID=@ReservationID)
			BEGIN
				OPEN @RFDIDCursor
				FETCH NEXT FROM @RFDIDCursor
				INTO @RFDID
				WHILE @@FETCH_STATUS = 0
				BEGIN

					UPDATE ReservationsFirmsDetails SET TableID=NULL WHERE RFDID=@RFDID

					FETCH NEXT FROM @RFDIDCursor
					INTO @RFDID

				END
				CLOSE @RFDIDCursor
				DEALLOCATE @RFDIDCursor
			END

			UPDATE Reservations SET EmployeeID=NULL WHERE ReservationID=@ReservationID

	DECLARE @errorMsg nvarchar(2048)='Cannot add confirm reservation. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO



CREATE PROCEDURE AddDiscount
AS 
BEGIN
	BEGIN TRY 
		
		INSERT INTO Discounts(StartDate)
		VALUES (GETDATE())
		DECLARE  @DiscountID int
		SELECT @DiscountID=SCOPE_IDENTITY()
	END TRY 
	BEGIN CATCH
	DELETE FROM Discounts
		WHERE DiscountID=@DiscountID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new discount. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE AddValueForDiscount
	@DiscountID int,
	@Type varchar(50),
	@Value int
AS 
BEGIN
	DECLARE @SetID INT;
	BEGIN TRY 
		IF
		(
			(@Value<=0)
		)
		BEGIN
			;THROW 52000, 'Value must be greater than 0.',1
		END

		IF NOT EXISTS
		(
			(SELECT SetID FROM DiscountsSet WHERE SetName=@Type)
		)
		BEGIN
			INSERT INTO DiscountsSet(SetName)
			VALUES (@Type)
			SELECT @SetID=SCOPE_IDENTITY()
		END
		ELSE
		BEGIN
			SET @SetID=
			(
				(SELECT SetID FROM DiscountsSet WHERE SetName=@Type)
			)
		END

		INSERT INTO DiscountSetDetails(DiscountID,SetID,Value)
		VALUES (@DiscountID,@SetID,@Value)
	END TRY 
	BEGIN CATCH
	DELETE FROM DiscountSetDetails
		WHERE DiscountID=@DiscountID AND SetID=@SetID
	DECLARE @errorMsg nvarchar(2048)='Cannot add new discount value. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO


CREATE PROCEDURE UpdateReservationRequirements
	@WZValue int,
	@WKValue int
AS 
BEGIN
	BEGIN TRY

	IF
	(@WZValue)<0 OR (@WKValue)<0
	BEGIN
		;THROW 52000, 'Value must be greater than 0.',1
	END

	UPDATE ReservationRequirements  SET WKValue=@WKValue, WZValue=@WZValue

	END TRY 
	BEGIN CATCH

	DECLARE @errorMsg nvarchar(2048)='Cannot update reservation requirements. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO

CREATE PROCEDURE UpdateDish
	@DishName varchar(50),
	@NewDishName varchar(50),
	@Description varchar(500),
	@MinStockValue int,
	@BasicDishPrice decimal(10,2),
	@StartUnits int
AS 
BEGIN
	DECLARE @DishID int
	BEGIN TRY
	
	IF NOT EXISTS 
	(
	(SELECT DishID FROM Dishes WHERE DishName=@DishName)
	)
	BEGIN
		;THROW 52000, 'Dish does not exist.',1
	END

	IF 
	(
	@BasicDishPrice<=0
	)
	BEGIN
		;THROW 52000, 'Basic dish price has to be greater than 0.',1
	END

	SET @DishID =
	(
		(SELECT DishID FROM Dishes WHERE DishName=@DishName)
	)
	UPDATE Dishes  SET DishName=@NewDishName, Description=@Description,MinStockValue=@MinStockValue,StartUnits=@StartUnits,BasicDishPrice=@BasicDishPrice WHERE DishID=@DishID

	END TRY 
	BEGIN CATCH

	DECLARE @errorMsg nvarchar(2048)='Cannot update dish. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO


CREATE PROCEDURE UpdateCategory
	@CategoryName varchar(50),
	@NewCategoryName varchar(50),
	@Description varchar(500)
AS 
BEGIN
	DECLARE @CategoryID int
	BEGIN TRY
	
	IF NOT EXISTS 
	(
	(SELECT CategoryID FROM Categories WHERE CategoryName=@CategoryName)
	)
	BEGIN
		;THROW 52000, 'Category does not exist.',1
	END

	SET @CategoryID =
	(
		(SELECT CategoryID FROM Categories WHERE CategoryName=@CategoryName)
	)
	UPDATE Categories  SET CategoryName=@NewCategoryName, Description=@Description WHERE CategoryID=@CategoryID

	END TRY 
	BEGIN CATCH

	DECLARE @errorMsg nvarchar(2048)='Cannot update category. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO



CREATE PROCEDURE ChangeMenu
AS 
BEGIN
	BEGIN TRY
	DECLARE @InMenu int
	DECLARE @AllDishes int
	DECLARE @Counter int
	DECLARE @NewDish int
	SET @InMenu =
	(
		SELECT COUNT(*) FROM DishesHistory as DH
		INNER JOIN Dishes AS D ON D.DishID=DH.DishID
		INNER JOIN Categories AS C ON C.CategoryID=D.CategoryID
		WHERE OutMenuDate IS NULL AND C.CategoryName!='Owoce morza' 
	)
	SET @AllDishes =
		(
			SELECT COUNT(*) FROM (
				SELECT ROW_NUMBER() OVER ( ORDER BY Dish.DishID) as RowDish,Dish.DishID FROM 
				(
				SELECT DISTINCT D.DishID, ROW_NUMBER() OVER (PARTITION BY D.DishID ORDER BY D.DishID) AS Row
				FROM Dishes as D
				INNER JOIN Categories AS C ON C.CategoryID=D.CategoryID
				LEFT JOIN DishesHistory AS DH ON DH.DishID=D.DishID
				WHERE C.CategoryName!='Owoce morza' AND ((OutMenuDate IS NOT NULL AND DATEDIFF(DAY,GETDATE(),OutMenuDate)<1) OR DH.DishesHistoryID IS NULL)
				AND D.DishID NOT IN (SELECT D1.DishID FROM Dishes as D1
				INNER JOIN DishesHistory AS DH1 ON DH1.DishID=D1.DishID
				WHERE DH1.OutMenuDate IS NULL OR DATEDIFF(DAY,GETDATE(),DH1.OutMenuDate)>=1)
				)
				Dish WHERE Row = 1
				)
				FinallDish
		)

	IF(@AllDishes=0)
	BEGIN
		;THROW 52000, 'There is no dishes to add.',1
	END
	
	

	SET @Counter = (
		CEILING(@InMenu/2)
	)

	IF(@Counter>@AllDishes)
	BEGIN
	SET @Counter=@AllDishes
	END

	DECLARE @MenuCursor CURSOR;
		DECLARE @DishIDInMenu int;
		SET @MenuCursor = CURSOR FOR 
			SELECT TOP 100 PERCENT DishesHistoryID FROM DishesHistory as DH
			INNER JOIN Dishes AS D ON D.DishID=DH.DishID
			INNER JOIN Categories AS C ON C.CategoryID=D.CategoryID
			WHERE OutMenuDate IS NULL AND C.CategoryName!='Owoce morza' AND DATEDIFF(DAY,GETDATE(),DH.InMenuDate)<0  ORDER BY InMenuDate

		BEGIN
			OPEN @MenuCursor
			FETCH NEXT FROM @MenuCursor
			INTO @DishIDInMenu
			WHILE @@FETCH_STATUS = 0
			BEGIN
				IF(@Counter>0)
					BEGIN
					UPDATE DishesHistory SET OutMenuDate=DATEADD(day, 1, GETDATE()) WHERE DishesHistoryID=@DishIDInMenu
					SET @Counter=(@Counter-1)
					END
				FETCH NEXT FROM @MenuCursor
				INTO @DishIDInMenu
			END
			CLOSE @MenuCursor
			DEALLOCATE @MenuCursor
		END

		SET @Counter = (
			CEILING(@InMenu/2)
		)


		SET @AllDishes =
		(
			SELECT COUNT(*) FROM (
				SELECT ROW_NUMBER() OVER ( ORDER BY Dish.DishID) as RowDish,Dish.DishID FROM 
				(
					SELECT DISTINCT D.DishID, ROW_NUMBER() OVER (PARTITION BY D.DishID ORDER BY D.DishID) AS Row
					FROM Dishes as D
					INNER JOIN Categories AS C ON C.CategoryID=D.CategoryID
					LEFT JOIN DishesHistory AS DH ON DH.DishID=D.DishID
					WHERE C.CategoryName!='Owoce morza' AND ((OutMenuDate IS NOT NULL AND DATEDIFF(DAY,GETDATE(),OutMenuDate)<1) OR DH.DishesHistoryID IS NULL)
					AND D.DishID NOT IN (SELECT D1.DishID FROM Dishes as D1
					INNER JOIN DishesHistory AS DH1 ON DH1.DishID=D1.DishID
					WHERE DH1.OutMenuDate IS NULL OR DATEDIFF(DAY,GETDATE(),DH1.OutMenuDate)>=1)
				)
				Dish WHERE Row = 1
				)
			FinallDish 
		)

		IF(@AllDishes=0)
		BEGIN
			;THROW 52000, 'There is no dishes to add.',1
		END

		WHILE @Counter >0 AND @AllDishes>0
			BEGIN

				SET @NewDish =(
				SELECT FinallDish.DishID FROM (
					SELECT ROW_NUMBER() OVER ( ORDER BY Dish.DishID) as RowDish,Dish.DishID FROM 
					(
					SELECT DISTINCT D.DishID, ROW_NUMBER() OVER (PARTITION BY D.DishID ORDER BY D.DishID) AS Row
					FROM Dishes as D
					INNER JOIN Categories AS C ON C.CategoryID=D.CategoryID
					LEFT JOIN DishesHistory AS DH ON DH.DishID=D.DishID
					WHERE C.CategoryName!='Owoce morza' AND ((OutMenuDate IS NOT NULL AND DATEDIFF(DAY,GETDATE(),OutMenuDate)<1) OR DH.DishesHistoryID IS NULL)
					AND D.DishID NOT IN (SELECT D1.DishID FROM Dishes as D1
					INNER JOIN DishesHistory AS DH1 ON DH1.DishID=D1.DishID
					WHERE DH1.OutMenuDate IS NULL OR DATEDIFF(DAY,GETDATE(),DH1.OutMenuDate)>=1)
					)
					Dish WHERE Row = 1
					)
					FinallDish WHERE RowDish = FLOOR(RAND()*(@AllDishes)+1)
				)
				
			
			INSERT INTO DishesHistory(DishPrice,InMenuDate,UnitsInStock,DishID)
			VALUES (
			(SELECT BasicDishPrice FROM Dishes WHERE DishID=@NewDish),
			 DATEADD(DAY, 1, GETDATE()),
			(SELECT StartUnits FROM Dishes WHERE DishID=@NewDish),
			@NewDish
			)

			SET @AllDishes=(@AllDishes-1)
			SET @Counter=(@Counter-1)

		END

	END TRY 
	BEGIN CATCH

	DECLARE @errorMsg nvarchar(2048)='Cannot update menu. Error message: '
	+ERROR_MESSAGE();
	THROW 52000, @errorMsg,1;
	END CATCH
END
GO