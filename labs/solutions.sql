-- 1: test de funcionamiento de la base de datos.
SELECT * FROM SalesLT.Address;   -- Devuelve la tabla de direcciones.
SELECT COUNT(*) FROM SalesLT.Address;   -- Devuelve el número de registros que hay en la tabla direcciones.


-- 2: query que devuelve los productos y su categoría, correspodientes a los 20 primeros. Estos se ordenan alfabéticamente.
SELECT TOP 20 pc.Name as CategoryName, p.name as ProductName
FROM SalesLT.ProductCategory pc JOIN SalesLT.Product p ON pc.productcategoryid= p.productcategoryid
ORDER BY CategoryName;


-- 3: devuelve el nombre de cada producto y la cantidad total vendida de ese producto, agrupándose para cada nombre de producto. Se ordenan utilizando la cantidad total.
SELECT p.name AS Product, count(*) AS Total
FROM SalesLT.SalesOrderHeader AS soh
    INNER JOIN SalesLT.SalesOrderDetail AS shd ON soh.SalesOrderID = shd.SalesOrderID
    INNER JOIN SalesLT.Product AS p ON shd.ProductID = p.ProductID
GROUP BY p.name
ORDER BY 2;


-- 4: Cuenta el número de productos, agrupados por categoría y nombre de producto. Ordena los resultados primero los registros primero por la primera columna y después
--    por la segunda.
SELECT pc.Name AS Category, p.name AS Product, SUM(sod.OrderQty) AS 'Total Qty'
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = p.ProductCategoryID
GROUP BY pc.Name, p.Name
ORDER BY 1, 2;


-- 5: devuelve las cantidades totales de productos vendidos, agrupados por categoría y nombre de producto. Estos se filtran para obtener solo los registros donde el número
--    de pedidos distintos sea mayor o igual a 8. Se ordenan los registros primero por categoría y después por nombre de producto.
SELECT pc.Name AS 'Category', p.name AS 'Product', SUM(sod.OrderQty) AS 'Total Qty'
FROM SalesLT.SalesOrderHeader AS soh
    INNER JOIN SalesLT.SalesOrderDetail AS sod ON p.ProductID = sod.ProductID
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = p.ProductCategoryID
GROUP BY GROUPING SETS ((pc.Name), (pc.Name, p.Name))
HAVING COUNT(DISTINCT shd.SalesOrderID) >= 8
ORDER BY 1, 2;


-- 6: devuelve el ID de producto, la categoría, el nombre de producto y el tamaño del mismo. 
SELECT p.ProductID, pc.Name AS 'Category', p.Name AS 'Product', p.[Size]
    , ROW_NUMBER() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Row Number Per Category & Size'
    , RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Rank Per Category & Size'
    , DENSE_RANK() OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Size) AS 'Dense Rank Per Category & Size'
    , NTILE(2) OVER (PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'NTile Per Category & Name'

    , SUM(p.StandardCost) OVER() AS 'Standard Cost Grand Total'
    , SUM(p.StandardCost) OVER(PARTITION BY p.ProductCategoryID) AS 'Standard Cost Per Category'
    
    , LAG(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Previous Product Per Category'
    , LEAD(p.Name, 1, '-- NOT FOUND --') OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Next Product Per Category'

    , FIRST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'First Product Per Category'
    , LAST_VALUE(p.Name) OVER(PARTITION BY p.ProductCategoryID ORDER BY p.Name) AS 'Last Product Per Category'
FROM SalesLT.Product AS p
    INNER JOIN SalesLT.ProductCategory AS pc ON p.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name, p.Name
LIMIT 20;