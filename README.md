# Aussie Bikes Data Warehouse
The project outlines the implementation of a robust data warehouse using Microsoft SSIS based on a case scenario involving Aussie Bikes, its sales system and ER Model. The data was consolidated from multiple operational tables in the sales system to optimize for data driven decision-making. 

I have attached the data sources, the backup file of the created data warehouse, images of the sales system ER model and the corresponding dimensional model, SQL Queries, stored procedures, screenshots of query outputs, and screenshots of the ETL Transformation steps in SSIS.

## AUSSIE BIKES CASE SCENARIO

Aussie Bikes (OZZB) specialises in manufacturing and selling three models of bicycles: (1) mountain bikes, (2) road bikes, and (3) touring bikes. Even though OZZB's primary business is focused on bicycle sales, it also sells accessories for bikers, such as bottles, bike racks, and brakes. In recent years, OZZB has extended to sports apparel, such as caps, gloves, and jerseys. Additionally, some portion of business includes sales of components like chains and derailleurs. While OZZB mainly manufactures bicycles, it purchases the apparel and the components from the other vendors. OZZB is not only in the business of manufacturing but also in the business of reselling. 

OZZB does not own any traditional brick-and-mortar stores for retailing, but instead, it sells items in bulk to retail stores as a wholesaler. However, OZZB uses an internet platform for the retail sales to the individual customers. The OZZB business model divides customers into retail stores that sell bikes and individual customers. Overall, OZZB's customer base includes over 635 stores, over 18,484 personal customers, and a sales force of 17 salespeople who sell the products to customers. On the supply side, OZZB utilises services from over 100 vendor companies serving as suppliers of components, accessories, clothing, and raw materials. In recent years, OZZB has been a profitable and very successful business venture with a global customer base across the United States, Canada, Australia, the United Kingdom, France, and Germany. The company is eying an expansion of business operations but lacks a clear understanding of its market. 

Amy is a newly hired manager and is tasked with the responsibility of building a better understanding of their current business before making the expansion decisions. In a recent business conference, Amy heard from vendors that business analytics can provide the business with the capability to make more informed decisions. She also discovered that the OZZB lacks the capabilities to make data-driven decisions as the board members rely on transactional databases to fetch the data. Amy identified the need for a data warehouse as a first step required for the expansion of business operations. 

In a recent meeting, the board approved hiring a business analyst consultant to provide analytic insights regarding the profitability of various products. You have been hired as a business analyst consultant to propose a business analytics solution to the management team. Your job is to present a prototype of a data warehouse and make a business case by identifying the key customers, profitable products, and sales territory in the last two years.

Amy has specifically requested, a) Data Model for the Data Warehouse, b) Description of data integration process (ETL), c) Sample Analytical queries.
1. Who are the key customers in Australia?
2. Which products were the most profitable in 2014?
3. Which sales territories are the most profitable during December 2013? 

### Sales System ER Model
![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/99ca70ca-7e34-468e-8436-199407d8018d)

## REPORT

### Executive Summary
Data is an asset that can allow us to get insights on business activities, consumer preferences, and make critical decisions. The transactional databases currently in place are normalised and contains many tables. They are designed for efficient data writing and simple data retrieval but are not ideal for answering analytical questions as it requires accessing and joining data from multiple tables before aggregating the data. 

To optimise and organise data for answering analytical queries, performing numerical aggregations, and understand various dimensions, a data warehouse prototype has been created. The data warehouse is designed with a denormalised data model (the dimensional model) and contains a separate informational database to optimize data reading and aggregating capabilities, support complex querying, and meet analytical information needs.

The dimensional model is based on the multi-dimensional model of data and is designed for retrieval-only databases. It is simple, intuitive, and allows us to focus on process measurement events such as profit and associated dimensions that provide descriptive context, i.e., fact tables and dimension tables. The dimensional model is designed before implementing the data warehouse.

The data from the operational systems is then combined and transformed (ETL) into a multi-dimensional model to extract valuable data (integrated, non-volatile, subject oriented, and time-variant data) which we then deposit in the data warehouse (informational database as per the dimensional model). The data warehouse in turn allows us to access a unified version of truth that can support decision-making.

This dimensional model has helped us garner the following insights:
* Richard Carey is our top customer in Australia based on net profit contributions.
* In 2014, the top 10 profitable products are all bikes. 60% of them are mountain bikes, 30% are touring bikes, and 10% are road bikes.
* In December 2013, our most profitable sales territory was Australia.

### The Dimensional Model
![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/8e0c3464-02ea-41df-b758-3fc4fc8b6436)

I used Ralph Kimball’s four step process in developing the dimensional model:

<ins>Step 1: Select the business process.</ins>

We will be focussing on the Sales Process (OrderQty, LineTotal, Profit, etc.) as our objective is to analyse profitability across dimensions such as customers and products.

<ins>Step 2: Define the Data Grain.</ins>

Each data grain represents an individual customer, unique product (including its quantity per order), sales territory, salesperson involved in the transaction, and the day of transaction (day is at the atomic grain level despite OrderDate using datetime data type; time isn’t recorded as per data realities of the system). Data is at the lowest possible details for provision of analytical flexibility.

<ins>Step 3: Identify Dimensions. </ins>

Here the dimensions are customer, product, territory, salesperson, and date. Surrogate keys were generated for each dimension to connect the dimensions and facts while preserving the natural key. This allows us to save storage space and prevent potential disruptions when records of the operational sources change over time. A Date dimension has also been included as they are fundamental for tracking changes across time periods.

Hierarchies were collapsed across the dimensions. Information from the Product, ProductSubCategory, ProductCategory, ProductModel tables in the operational database were collapsed into the product dimension. The Customers, Address, StateProvince, and CountryRegion tables were collapsed into the customer dimension. The SalesPerson SalesPersonDetails, SalesTerritory, StateProvince, and CountryRegion tables were collapsed into the salesperson dimension. Adding additional attributes helps to manage the complexity while logically maintaining the hierarchical structure of the data in the same dimensional table. For example, ProductSubCategoryName and ProductCategoryName were additional attributes added to the product dimension to provide additional flexibility in the analysis.

<ins>Step 4: Identify the Fact Measure.</ins>

The fact table uses a composite key consisting of the keys of all the dimension tables (CustomerKey, ProductKey, TerritoryKey, SalesPersonKey, OrderDateKey). 
The facts correspond to the measurements of sales events at a point in space and time. Here we include the facts LineTotal, LineTax, LineFreight, OrderQty, UnitPrice, UnitPriceDiscount, StandardCost, ListPrice, Profit_Tax_Freight, Profit_StandardCost, Profit_Tax_Freigth_StandardCost. 

These are numerical and additive in nature and supports mathematical operations such as aggregation for analysis. The LineTax and LineFreight facts are the tax amounts and freight costs of the transaction distributed evenly across the line items. 

Profit_Tax_Freight, Profit_StandardCost, and Profit_Tax_Freigth_StandardCost represent profits calculated in different ways. 
* Profit_Tax_Freight = LineTotal – LineTax – LineFreight
* Profit_StandardCost = LineTotal – (StandardCost * OrderQty)
* Profit_Tax_Freigth_StandardCost = LineTotal – LineTax – LineFreight – (StandardCost*OrderQty)


Note: To navigate the appropriate equation for calculating profit we need to conduct an initial assessment as recommended by Kimball to understand the data realities, business context, and end-user requirements. I will proceed with Profit_Tax_Freigth_StandardCost as profit for the purposes of this project and answer analytical queries.

### Implementaion of the Dimensional Model (ETL with Microsoft SSIS)
1. **Dimensional Tables Implementation** ![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/f37baf02-617e-425e-bcce-1514e2afa548)
        ![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/ea28025a-35c4-4260-ae39-50f3a4381fe9)

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/199d9efb-1eb1-47dc-b2ee-14e013cc4d0e)

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/baba8b29-0a2d-46ce-bd21-69203e7b87a5)

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/54ecf63a-95a6-4255-a3c6-b6133ba3ed6d)

3. **Fact Table Implementation**

 ![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/138d0641-2e25-41e0-b916-bee2b024af9d)
 
5. **The Implementation Process**

Relevant components of the data warehouse architecture:

**Source Data Systems:**

Before we can integrate data into a dimensional model, we need to first identify the source data systems. Our main data source is the internal sales system modelled as a transactional database. We also have an internally sourced flat file that contains the names of the Aussie Bikes salespeople.

**Data Staging Area:**

After identifying the data sources, we then conduct Extract, Transform, Load (ETL) with SSIS. ETL facilitates creation of the dimensionally modelled data through data integration, transformation, cleaning and is vital in ensuring the quality of data and smooth functioning of the data warehouse.

We extract the data in the sales system from SQL Server Management Studio using an ADO Net Source in SSIS. To extract the flat file, which is stored as a .xlsx file, the file had to be converted to a CSV file before it could be read as a flat file source in SSIS.

In the transformation phase, we fix the data quality issues and prepare the data to load into the dimensional model. 

* In the flat file, the SalesPersonID attribute is converted into a 4 byte signed integer from a general string data type to match the data type of SalesPersonID in the SalesPerson table. The data types need to match to perform an SSIS merge join task.
* For the dimension and fact tables, we merge data from various tables in the sales system using a merge join task.
* Artificially generated surrogate keys are added through SQL table creation queries in the ADO Net Destination before loading data into the dimensional tables in the data warehouse.
* In the DateDim table, we store additional information regarding Day, Month, and Year, based on the DateID attribute from the Dates table in the operational database via a derived column task.
* To calculate tax and freight amounts for each line item, we get the aggregate sum of the OrderQty attribute per order (since LineTax=TaxAmt*(OrderQty/Sum(OrderQty))) via an aggregate task. With the calculated sum of OrderQty per order, we can derive the LineTax and LineFreight attributes via a derived column task. Once we have LineTax and LineFreight attributes, Profit_Tax_Freight, Profit_StandardCost, and Profit_Tax_Freigth_StandardCost (as defined earlier) can be calculated via an additional derived column task.
* We convert OrderDate, DueDate, and ShipDate from datetime data type to date data type via type casting and the derived column SSIS task. We do this for looking up matching date keys in the DateDim dimensional table, since DateID in DateDim has date data type.
* For the fact table, we can obtain the surrogate keys from the constructed dimensional tables via a lookup task by matching the natural key in the fact table with the corresponding key in the dimensional table.

Once the data is transformed, we can load the processed data into the data warehouse.

**Data and Meta-Data Storage Area:**

The final raw data is loaded onto the data warehouse, ‘OZZB_SalesDataWarehouse’, a database in SQL Server Management Studio via SSIS ADO Net Destination. 

### Key Customers in Australia

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/3129af17-8672-4036-a3ba-54e8f5d6d550)

Richard Carey is our top customer in Australia based on net profit contributions, contributing ~14247$ in profits. His profit contribution is ~4.6 times that of our 2nd top customer in Australia, Meagan Madan. Furthermore, 80% of our key customers from Australia seem to be from either New South Wales or Victoria.

**SQL:**

WITH cte1 AS (SELECT C1.CustomerKey, CAST(ROUND(SUM(F.Profit_Tax_Freigth_StandardCost),1) AS FLOAT) AS CustomerProfitAustralia
	FROM SalesOrderFact F
	JOIN CustomerDim C1
	ON F.CustomerKey=C1.CustomerKey
	WHERE C1.CountryRegionName='Australia'
	GROUP BY C1.CustomerKey
)
SELECT TOP 10 cte1.CustomerKey, C2.CustomerID, cte1.CustomerProfitAustralia, C2.FirstName + ' ' + C2.LastName AS FullName, C2.City, C2.StateProvinceName AS State
FROM cte1 
JOIN CustomerDim C2
ON cte1.CustomerKey=C2.CustomerKey
ORDER BY cte1.CustomerProfitAustralia DESC;

### Most Profitable Products 2014

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/cb659cdb-21ac-4575-ac1d-e44f91a39ae8)

In 2014, our top 10 profitable products are all bikes! Among the top 10 bike products, 60% are mountain bikes, 30% are touring bikes, and 10% are road bikes. Also, the most profitable mountain bike makes ~3.4 that of the most profitable touring bike. Most of these top bikes are either black or silver in colour.

**SQL:**

WITH cte1 AS (SELECT P.ProductKey, CAST(ROUND(SUM(F.Profit_Tax_Freigth_StandardCost),1) AS FLOAT) AS ProductProfit2014
	FROM SalesOrderFact F
	JOIN ProductDim P
	ON F.ProductKey=P.ProductKey
	JOIN DateDim D
	ON F.OrderDateKey=D.DateKey
	WHERE D.Year=2014
	GROUP BY P.ProductKey
)
SELECT TOP 10 cte1.ProductKey, cte1.ProductProfit2014, P.ProductName, P.ProductCategoryName AS Category, P.ProductSubCategoryName AS SubCategory, P.ProductModelName AS Model
FROM cte1 
JOIN ProductDim P
ON cte1.ProductKey=P.ProductKey
ORDER BY cte1.ProductProfit2014 DESC;

### Most Profitable Sales Territories in December 2013

![image](https://github.com/CalvinJohn99/Aussie-Bikes-Data-Warehouse/assets/40469219/30885754-7c83-4d52-ab0d-66f0ca5ab3c7)

In December 2013, our most profitable sales territory is Australia in the pacific group with ~148812.5$ in profits for the month. Although Australia is the most profitable sales territory, our 2nd and 3rd most profitable territories, Northwest and Southwest respectively, contributed to more unit sales and dollar sales for the month. This could perhaps be because of lower costs incurred within Australia.

**SQL:**

WITH cte1 AS (SELECT T1.TerritoryKey, CAST(ROUND(SUM(Profit_Tax_Freigth_StandardCost),1) AS FLOAT) AS TerritoryProfitDec2013, SUM(F.OrderQty) AS UnitSales, CAST(ROUND(SUM(F.LineTotal),1) AS FLOAT) AS DollarSales
	FROM SalesOrderFact F
	JOIN SalesTerritoryDim T1
	ON F.TerritoryKey=T1.TerritoryKey
	JOIN DateDim D
	ON F.OrderDateKey=D.DateKey
	WHERE D.Year=2013 AND D.Month=12
	GROUP BY T1.TerritoryKey
)
SELECT TOP 5 cte1.*, T2.TerritoryName, T2.TerritoryGroup
FROM cte1
JOIN SalesTerritoryDim T2
ON cte1.TerritoryKey=T2.TerritoryKey
ORDER BY cte1.TerritoryProfitDec2013 DESC;

By denormalizing the data, the dimensional model has made it simple to answer analytical queries (as observed from the simpler SQL queries), perform numerical aggregations, and understand various dimensions.


