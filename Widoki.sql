Create view Menu as 
Select D.DishName,D.Description,DH.DishPrice from DishesHistory as DH 
inner join Dishes as D on D.DishID=DH.DishID 
where OutMenuDate is null 

Create view DishesToOrder as 
Select D.DishName,D.Description,DH.DishPrice from DishesHistory as DH 
inner join Dishes as D on D.DishID=DH.DishID 
where D.MinStockValue>DH.UnitsInStock and OutMenuDate is null 

Create view DishesCategories as 
Select D.DishName,C.CategoryName,C.Description from Dishes as D 
inner join Categories as C on D.CategoryID=C.CategoryID

Create view DishesHistoryPrices as 
Select TOP(100) Percent D.DishName,DH.DishPrice,DH.InMenuDate,DH.OutMenuDate from DishesHistory as DH 
inner join Dishes as D on D.DishID=DH.DishID 
order by D.DishID,DH.DishPrice DESC

Create view OrdersToDo as 
Select OrderID,CustomerID,EmployeeID,OrderDate,O.ReceiveDate,PT.PaymentName from Orders  as O
inner join PaymentType as PT on  O.PaymentTypeID=PT.PaymentTypeID
where ReceiveDate>getdate()

Create view OrdersPriceForToday as 
Select O.OrderID,SUM(OD.DishPrice*OD.Quantity),O.OrderDate as 'Price' from Orders as o
inner join OrderDetails as OD on O.OrderID=OD.OrderID
where DATEDIFF(day,O.ReceiveDate,getdate())=0
group by O.OrderID,O.OrderDate


Create view CurrentDiscounts as 
Select D.DiscountID,DS.SetName,DSD.Value from Discounts as D 
inner join DiscountSetDetails as DSD on D.DiscountID=DSD.DiscountID
inner join DiscountsSet as DS on DS.SetID=DSD.SetID
where D.EndDate is null

Create view FirmsEmployees as 
Select C.CustomerID,CI.FirstName+' '+CI.LastName as 'Name',CF.CompanyName from Customers as C
inner join CustomerIndividuals as CI on C.CustomerID=CI.CustomerID
inner join CustomerFirmsEmployees as CFE on CFE.CustomerID=CI.CustomerID
inner join CustomerFirms as CF on CFE.FirmID=CF.CustomerID

Create view CustomerDiscountFirstType as 
Select CI.CustomerID,CI.FirstName+' '+CI.LastName as 'Name',CDFT.ReceivedDate,DS.SetName,DSD.Value from CustomerIndividuals as CI
inner join CustomerDiscountFT as CDFT on CI.CustomerID=CDFT.CustomerID
inner join Discounts as D on D.DiscountID=CDFT.DiscountID
inner join DiscountSetDetails as DSD on D.DiscountID=DSD.DiscountID
inner join DiscountsSet as DS on DS.SetID=DSD.SetID


Create view CustomerDiscountsSecondType as 
Select CI.CustomerID,CI.FirstName+' '+CI.LastName as 'Name',CDST.ReceivedDate,CDST.UseDate,DS.SetName,DSD.Value from CustomerIndividuals as CI
inner join CustomerDiscountsST as CDST on CI.CustomerID=CDST.CustomerID
inner join Discounts as D on D.DiscountID=CDST.DiscountID
inner join DiscountSetDetails as DSD on D.DiscountID=DSD.DiscountID
inner join DiscountsSet as DS on DS.SetID=DSD.SetID

Create view DishPopularity as 
Select TOP(100) percent D.DishID,D.DishName,isnull(SUM(OD.Quantity),0) as 'Quantity' from OrderDetails as OD
inner join DishesHistory as DH on OD.DishesHistoryID=DH.DishesHistoryID
right join Dishes as D on D.DishID=DH.DishID
group by OD.DishesHistoryID,D.DishID,D.DishName
order by 3 DESC

Create view DishIncome as 
Select TOP(100) percent D.DishID,D.DishName,isnull(SUM(OD.Quantity*OD.DishPrice),0) as 'Income' from OrderDetails as OD
inner join DishesHistory as DH on OD.DishesHistoryID=DH.DishesHistoryID
right join Dishes as D on D.DishID=DH.DishID
group by OD.DishesHistoryID,D.DishID,D.DishName
order by 3 DESC

Create view ReservationsToday as 
Select * from Reservations as R where DATEDIFF(day,R.ReservationDate,getdate())=0

Create view IndividualsReservationsCount as 
Select CI.CustomerID,CI.FirstName+' '+CI.LastName as 'Name', isnull(COUNT(RI.ReservationID),0) as 'Count' from ReservationsIndividuals as RI 
right join CustomerIndividuals as CI on CI.CustomerID=RI.CustomerID
group by RI.ReservationID,CI.CustomerID,CI.FirstName,CI.LastName

Create view FirmsReservationsCount as 
Select CF.CustomerID,CF.CompanyName, isnull(COUNT(RF.ReservationID),0) as 'Count' from ReservationsFirms as RF 
right join CustomerFirms as CF on CF.CustomerID=RF.FirmID
group by RF.ReservationID,CF.CustomerID,CF.CompanyName

Create view ReservationsToAccept as
Select R.ReservationID,R.ReservationDate,CI.FirstName+' '+CI.LastName as 'Name' from Reservations as R
inner join ReservationsIndividuals as RI on RI.ReservationID=R.ReservationID
inner join CustomerIndividuals as CI on CI.CustomerID=RI.CustomerID
where EmployeeID is null
union
Select R.ReservationID,R.ReservationDate,CF.CompanyName as 'Name' from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join CustomerFirms as CF on CF.CustomerID=RF.FirmID
where EmployeeID is null


Create view ReservationsLastMonth as 
Select * from Reservations where DATEDIFF(MONTH,ReservationDate,Getdate())=0

Create view ReservationsLastWeek as 
Select * from Reservations where DATEDIFF(WEEK,ReservationDate,Getdate())=0 




Create view FreeTablesForToday as
Select T.TableID,T.Places from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsEmployees as RFE on RF.ReservationID=RFE.ReservationID
right join Tables as T on RFE.TableID=T.TableID and datediff(day,getdate(),R.ReservationDate)=0
where R.ReservationID is null
intersect
Select T.TableID,T.Places from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsDetails as RFD on RF.ReservationID=RFD.ReservationID
right join Tables as T on RFD.TableID=T.TableID and datediff(day,getdate(),R.ReservationDate)=0
where R.ReservationID is null
intersect
Select T.TableID,T.Places from Reservations as R
inner join ReservationsIndividuals as RI on RI.ReservationID=R.ReservationID
right join Tables as T on RI.TableID=T.TableID and datediff(day,getdate(),R.ReservationDate)=0
where R.ReservationID is null




Create view ReservatedTablesLastMonth as
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsEmployees as RFE on RF.ReservationID=RFE.ReservationID
right join Tables as T on RFE.TableID=T.TableID and datediff(month,getdate(),R.ReservationDate)=0
where R.ReservationID is not null
union
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsDetails as RFD on RF.ReservationID=RFD.ReservationID
right join Tables as T on RFD.TableID=T.TableID and datediff(month,getdate(),R.ReservationDate)=0
where R.ReservationID is not null
union
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsIndividuals as RI on RI.ReservationID=R.ReservationID
right join Tables as T on RI.TableID=T.TableID and datediff(month,getdate(),R.ReservationDate)=0
where R.ReservationID is not null

Create view ReservatedTablesLastWeek as
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsEmployees as RFE on RF.ReservationID=RFE.ReservationID
right join Tables as T on RFE.TableID=T.TableID and datediff(Week,getdate(),R.ReservationDate)=0
where R.ReservationID is not null
union
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsFirms as RF on RF.ReservationID=R.ReservationID
inner join ReservationsFirmsDetails as RFD on RF.ReservationID=RFD.ReservationID
right join Tables as T on RFD.TableID=T.TableID and datediff(Week,getdate(),R.ReservationDate)=0
where R.ReservationID is not null
union
Select R.ReservationID,R.ReservationDate,T.TableID from Reservations as R
inner join ReservationsIndividuals as RI on RI.ReservationID=R.ReservationID
right join Tables as T on RI.TableID=T.TableID and datediff(Week,getdate(),R.ReservationDate)=0
where R.ReservationID is not null




CREATE VIEW DiscountsThisMonth AS
SELECT D.DiscountID,D.StartDate,D.EndDate,DS.SetName,DSD.Value FROM Discounts AS D 
INNER JOIN DiscountSetDetails AS DSD ON D.DiscountID=DSD.DiscountID
INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
WHERE DATEDIFF(MONTH,GETDATE(),D.StartDate)=0

CREATE VIEW DiscountsThisWeek AS
SELECT D.DiscountID,D.StartDate,D.EndDate,DS.SetName,DSD.Value FROM Discounts AS D 
INNER JOIN DiscountSetDetails AS DSD ON D.DiscountID=DSD.DiscountID
INNER JOIN DiscountsSet AS DS ON DS.SetID=DSD.SetID
WHERE DATEDIFF(WEEK,GETDATE(),D.StartDate)=0


CREATE VIEW IncomePerCustomerIndividualThisMonth AS
SELECT CI.CustomerID,CI.FirstName+' '+CI.LastName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income' FROM CustomerIndividuals AS Ci
INNER JOIN Customers AS C ON CI.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(MONTH,GETDATE(),O.OrderDate)=0
GROUP BY CI.CustomerID,CI.FirstName,CI.LastName,C.Phone

CREATE VIEW IncomePerCustomerIndividualThisWeek AS
SELECT CI.CustomerID,CI.FirstName+' '+CI.LastName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income' FROM CustomerIndividuals AS Ci
INNER JOIN Customers AS C ON CI.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(WEEK,GETDATE(),O.OrderDate)=0
GROUP BY CI.CustomerID,CI.FirstName,CI.LastName,C.Phone

CREATE VIEW OrdersPerCustomerIndividualThisMonth AS
SELECT CI.CustomerID,CI.FirstName+' '+CI.LastName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income',O.OrderDate,O.OrderID FROM CustomerIndividuals AS Ci
INNER JOIN Customers AS C ON CI.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(MONTH,GETDATE(),O.OrderDate)=0
GROUP BY CI.CustomerID,CI.FirstName,CI.LastName,C.Phone,O.OrderDate,O.OrderID

CREATE VIEW OrdersPerCustomerIndividualThisWeek AS
SELECT CI.CustomerID,CI.FirstName+' '+CI.LastName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income',O.OrderDate,O.OrderID FROM CustomerIndividuals AS Ci
INNER JOIN Customers AS C ON CI.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(WEEK,GETDATE(),O.OrderDate)=0
GROUP BY CI.CustomerID,CI.FirstName,CI.LastName,C.Phone,O.OrderDate,O.OrderID




CREATE VIEW IncomePerCustomerFirmThisMonth AS
SELECT CF.CustomerID,CF.CompanyName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income' FROM CustomerFirms AS CF
INNER JOIN Customers AS C ON CF.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(MONTH,GETDATE(),O.OrderDate)=0
GROUP BY CF.CustomerID,CF.CompanyName,C.Phone

CREATE VIEW IncomePerCustomerFirmThisWeek AS
SELECT CF.CustomerID,CF.CompanyName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income' FROM CustomerFirms AS CF
INNER JOIN Customers AS C ON CF.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(WEEK,GETDATE(),O.OrderDate)=0
GROUP BY CF.CustomerID,CF.CompanyName,C.Phone

CREATE VIEW OrdersPerCustomerFirmThisMonth AS
SELECT CF.CustomerID,CF.CompanyName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income',O.OrderID,O.OrderDate FROM CustomerFirms AS CF
INNER JOIN Customers AS C ON CF.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(MONTH,GETDATE(),O.OrderDate)=0
GROUP BY CF.CustomerID,CF.CompanyName,C.Phone,O.OrderID,O.OrderDate

CREATE VIEW OrdersPerCustomerFirmThisWeek AS
SELECT CF.CustomerID,CF.CompanyName AS 'Name',C.Phone,SUM(OD.DishPrice*OD.Quantity) AS 'Income',O.OrderID,O.OrderDate FROM CustomerFirms AS CF
INNER JOIN Customers AS C ON CF.CustomerID=C.CustomerID
INNER JOIN Orders AS O ON O.CustomerID=C.CustomerID
INNER JOIN OrderDetails AS OD ON O.OrderID=OD.OrderID
WHERE DATEDIFF(WEEK,GETDATE(),O.OrderDate)=0
GROUP BY CF.CustomerID,CF.CompanyName,C.Phone,O.OrderID,O.OrderDate


