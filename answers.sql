/* ================================
   Question 1 
   ================================ */

/* Target table in 1NF */
CREATE TABLE ProductDetail_1NF (
  OrderID       INT       NOT NULL,
  CustomerName  VARCHAR(100) NOT NULL,
  Product       VARCHAR(100) NOT NULL,
  PRIMARY KEY (OrderID, Product)
);


WITH RECURSIVE split AS (
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(Products, ',', 1)) AS Product,
    CASE
      WHEN LOCATE(',', Products) > 0 THEN SUBSTRING(Products, LOCATE(',', Products) + 1)
      ELSE NULL
    END AS rest
  FROM ProductDetail
  UNION ALL
  SELECT
    OrderID,
    CustomerName,
    TRIM(SUBSTRING_INDEX(rest, ',', 1)) AS Product,
    CASE
      WHEN LOCATE(',', rest) > 0 THEN SUBSTRING(rest, LOCATE(',', rest) + 1)
      ELSE NULL
    END AS rest
  FROM split
  WHERE rest IS NOT NULL
)
INSERT INTO ProductDetail_1NF (OrderID, CustomerName, Product)
SELECT OrderID, CustomerName, Product
FROM split
WHERE Product <> '';


/* ================================
   Question 2 — Achieving 2NF
   
   ================================ */

/* Base tables */
CREATE TABLE Orders (
  OrderID       INT PRIMARY KEY,
  CustomerName  VARCHAR(100) NOT NULL
);

CREATE TABLE OrderItems (
  OrderID  INT NOT NULL,
  Product  VARCHAR(100) NOT NULL,
  Quantity INT NOT NULL,
  PRIMARY KEY (OrderID, Product),
  CONSTRAINT fk_orderitems_order
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

/* Populate Orders with distinct (OrderID, CustomerName) */
INSERT INTO Orders (OrderID, CustomerName)
SELECT DISTINCT OrderID, CustomerName
FROM OrderDetails;

/* Populate OrderItems with the line-level facts */
INSERT INTO OrderItems (OrderID, Product, Quantity)
SELECT OrderID, Product, Quantity
FROM OrderDetails;


