-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
1. Все товары, в названии которых есть "urgent" или название начинается с "Animal".
Вывести: ИД товара (StockItemID), наименование товара (StockItemName).
Таблицы: Warehouse.StockItems.
*/

SELECT TOP 10 *
FROM Warehouse.StockItems
WHERE 
	StockItemName LIKE '%urgent%'
	OR StockItemName LIKE 'Animal%'

/*
2. Поставщиков (Suppliers), у которых не было сделано ни одного заказа (PurchaseOrders).
Сделать через JOIN, с подзапросом задание принято не будет.
Вывести: ИД поставщика (SupplierID), наименование поставщика (SupplierName).
Таблицы: Purchasing.Suppliers, Purchasing.PurchaseOrders.
По каким колонкам делать JOIN подумайте самостоятельно.
*/

SELECT sup.SupplierID, sup.SupplierName
FROM Purchasing.Suppliers sup
    LEFT JOIN Purchasing.PurchaseOrders ord ON ord.SupplierID = sup.SupplierID
WHERE ord.SupplierID IS NULL

/*
3. Заказы (Orders) с ценой товара (UnitPrice) более 100$
либо количеством единиц (Quantity) товара более 20 штук
и присутствующей датой комплектации всего заказа (PickingCompletedWhen).
Вывести:
* OrderID
* дату заказа (OrderDate) в формате ДД.ММ.ГГГГ
* название месяца, в котором был сделан заказ
* номер квартала, в котором был сделан заказ
* треть года, к которой относится дата заказа (каждая треть по 4 месяца)
* имя заказчика (Customer)
Добавьте вариант этого запроса с постраничной выборкой,
пропустив первую 1000 и отобразив следующие 100 записей.

Сортировка должна быть по номеру квартала, трети года, дате заказа (везде по возрастанию).

Таблицы: Sales.Orders, Sales.OrderLines, Sales.Customers.
*/

select *
from (SELECT ord.OrderID
           , ord.OrderDate
           , DATENAME(month, ord.OrderDate)                   as 'month'
           , DATENAME(quarter, ord.OrderDate)                 as 'quarter'
           , CEILING(cast(month(ord.OrderDate) as float) / 4) as 'tret'
           , CustomerName
      FROM Sales.Orders ord
               left join sales.OrderLines sal on sal.OrderID = ord.OrderID
               left join sales.Customers cus on cus.CustomerID = ord.CustomerID
      WHERE sal.UnitPrice > 100
         or (sal.Quantity > 20 and ord.PickingCompletedWhen is not null)) as sub
order by quarter, tret, OrderDate;

select *
from (SELECT ord.OrderID
           , ord.OrderDate
           , DATENAME(month, ord.OrderDate)                   as 'month'
           , DATENAME(quarter, ord.OrderDate)                 as 'quarter'
           , CEILING(cast(month(ord.OrderDate) as float) / 4) as 'tret'
           , CustomerName
      FROM Sales.Orders ord
               left join sales.OrderLines sal on sal.OrderID = ord.OrderID
               left join sales.Customers cus on cus.CustomerID = ord.CustomerID
      WHERE sal.UnitPrice > 100
         or (sal.Quantity > 20 and ord.PickingCompletedWhen is not null)) as sub
order by quarter, tret, OrderDate
OFFSET 1000 ROWS
FETCH FIRST 100 ROWS ONLY;
