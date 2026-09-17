-- ============================================================
-- PROCUREMENT & SUPPLIER INTELLIGENCE
-- SQL BUSINESS ANALYSIS
-- ============================================================



-- ============================================================
-- DATABASE SETUP
-- ============================================================

CREATE DATABASE ProcurementAnalytics;
USE ProcurementAnalytics;

CREATE TABLE procurement (
    PO_ID VARCHAR(50),
    Supplier VARCHAR(100),
    Order_Date DATE,
    Delivery_Date DATE,
    Item_Category VARCHAR(100),
    Order_Status VARCHAR(50),
    Quantity INT,
    Unit_Price DECIMAL(12,2),
    Negotiated_Price DECIMAL(12,2),
    Defective_Units DECIMAL(12,2),
    Compliance VARCHAR(10),
    Delivery_Days INT
);


SELECT COUNT(*) AS Total_Rows
FROM ProcurementAnalytics.procurement;


-- ============================================================
-- BUSINESS ANALYSIS
-- ============================================================

--Q1 What is the overall scale of procurement, and how concentrated is our supplier base?

SELECT
    COUNT(DISTINCT PO_ID) AS Total_Purchase_Orders,
    COUNT(DISTINCT Supplier) AS Total_Suppliers,
    COUNT(DISTINCT Item_Category) AS Total_Categories,
    SUM(Quantity) AS Total_Quantity_Procured,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Total_Procurement_Spend
FROM ProcurementAnalytics.procurement;

-- Q2 Which suppliers account for the highest procurement spend?

SELECT
    Supplier,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Total_Spend
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Total_Spend DESC;


--Q3 Are we achieving meaningful savings through supplier price negotiation?

SELECT
    ROUND(SUM(Quantity * Unit_Price), 2) AS Original_Procurement_Value,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Negotiated_Procurement_Value,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price)), 2
    ) AS Total_Savings,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price))
        / SUM(Quantity * Unit_Price) * 100,
        2
    ) AS Savings_Percentage
FROM ProcurementAnalytics.procurement;

---Q4 Which suppliers are delivering the highest negotiation savings?

SELECT
    Supplier,
    ROUND(SUM(Quantity * (Unit_Price - Negotiated_Price)), 2) AS Total_Savings,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price))
        / SUM(Quantity * Unit_Price) * 100,
        2
    ) AS Savings_Percentage
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Total_Savings DESC;

-- Q5 Which suppliers have the best and worst delivery performance?

SELECT
    Supplier,
    ROUND(AVG(Delivery_Days), 2) AS Average_Delivery_Days
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Average_Delivery_Days;


-- Q6 Which suppliers have the highest defect rates?

SELECT
    Supplier,
    SUM(Defective_Units) AS Total_Defective_Units,
    SUM(Quantity) AS Total_Quantity,
    ROUND(
        SUM(Defective_Units) / SUM(Quantity) * 100,
        2
    ) AS Defect_Rate
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Defect_Rate DESC;

-- Q7 Which suppliers have the weakest compliance performance?

SELECT
    Supplier,
    SUM(CASE WHEN Compliance = 'Yes' THEN 1 ELSE 0 END) AS Compliant_Orders,
    COUNT(*) AS Total_Orders,
    ROUND(
        SUM(CASE WHEN Compliance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS Compliance_Rate
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Compliance_Rate DESC;
-- Q8 Which suppliers show the greatest combination of delivery, quality, and compliance risk?

SELECT
    Supplier,
    ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days,
    ROUND(SUM(Defective_Units) / SUM(Quantity) * 100, 2) AS Defect_Rate,
    ROUND(
        SUM(CASE WHEN Compliance = 'Yes' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS Compliance_Rate
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY
    Avg_Delivery_Days DESC,
    Defect_Rate DESC,
    Compliance_Rate ASC;
    
    -- Q9 Which item categories generate the highest procurement savings?

SELECT
    Item_Category,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price)),
        2
    ) AS Total_Savings,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price))
        / SUM(Quantity * Unit_Price) * 100,
        2
    ) AS Savings_Percentage
FROM ProcurementAnalytics.procurement
GROUP BY Item_Category
ORDER BY Total_Savings DESC;


-- Q10 What is the distribution of purchase orders across different order statuses?

SELECT
    Order_Status,
    COUNT(*) AS Number_of_Orders,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ProcurementAnalytics.procurement),
        2
    ) AS Order_Percentage
FROM ProcurementAnalytics.procurement
GROUP BY Order_Status
ORDER BY Number_of_Orders DESC;

-- Q11 Which item categories have the highest proportion of orders that are not fully delivered?

SELECT
    Item_Category,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN Order_Status <> 'Delivered' THEN 1
            ELSE 0
        END
    ) AS Incomplete_Orders,
    ROUND(
        SUM(
            CASE
                WHEN Order_Status <> 'Delivered' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Incomplete_Order_Percentage
FROM ProcurementAnalytics.procurement
GROUP BY Item_Category
ORDER BY Incomplete_Order_Percentage DESC;
-- Q12 Which suppliers have the highest proportion of orders that are not fully delivered?

SELECT
    Supplier,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN Order_Status <> 'Delivered' THEN 1
            ELSE 0
        END
    ) AS Incomplete_Orders,
    ROUND(
        SUM(
            CASE
                WHEN Order_Status <> 'Delivered' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Incomplete_Order_Rate
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Incomplete_Order_Rate DESC;

-- Q13 Which suppliers contribute the most procurement spend within each item category?
SELECT
    Item_Category,
    Supplier,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Total_Spend
FROM ProcurementAnalytics.procurement
GROUP BY Item_Category, Supplier
ORDER BY Item_Category, Total_Spend DESC; 

-- Q14 How does procurement spend change month by month?

SELECT
    YEAR(Order_Date) AS Order_Year,
    MONTH(Order_Date) AS Order_Month,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Monthly_Procurement_Spend
FROM ProcurementAnalytics.procurement
GROUP BY
    YEAR(Order_Date),
    MONTH(Order_Date)
ORDER BY
    Order_Year,
    Order_Month;
    
    -- Q15 Which item categories account for the largest procurement spend?

SELECT
    Item_Category,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Total_Spend
FROM ProcurementAnalytics.procurement
GROUP BY Item_Category
ORDER BY Total_Spend DESC;

-- Q16 Which supplier achieves the highest negotiation savings within each item category?

SELECT
    Item_Category,
    Supplier,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price)),
        2
    ) AS Total_Savings
FROM ProcurementAnalytics.procurement
GROUP BY
    Item_Category,
    Supplier
ORDER BY
    Item_Category,
    Total_Savings DESC;
   
-- Q17 What percentage of total procurement spend is contributed by each supplier?

SELECT
    Supplier,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Total_Spend,
    ROUND(
        SUM(Quantity * Negotiated_Price)
        / SUM(SUM(Quantity * Negotiated_Price)) OVER () * 100,
        2
    ) AS Spend_Share_Percent
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Spend_Share_Percent DESC;

-- Q18 Which suppliers have the lowest negotiation savings percentage?

SELECT
    Supplier,
    ROUND(
        SUM(Quantity * (Unit_Price - Negotiated_Price))
        / SUM(Quantity * Unit_Price) * 100,
        2
    ) AS Savings_Percentage
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Savings_Percentage ASC;

-- Q19 How much procurement spend is tied up in orders that are not fully delivered?

SELECT
    Order_Status,
    COUNT(*) AS Number_of_Orders,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Procurement_Value
FROM ProcurementAnalytics.procurement
WHERE Order_Status <> 'Delivered'
GROUP BY Order_Status
ORDER BY Procurement_Value DESC;

-- Q20 Which suppliers have the highest procurement value tied to incomplete orders?

SELECT
    Supplier,
    ROUND(SUM(Quantity * Negotiated_Price), 2) AS Incomplete_Order_Value
FROM ProcurementAnalytics.procurement
WHERE Order_Status <> 'Delivered'
GROUP BY Supplier
ORDER BY Incomplete_Order_Value DESC;

-- Q21 Which suppliers have the highest proportion of procurement value tied to incomplete orders?

WITH supplier_exposure AS (
    SELECT
        Supplier,
        SUM(Quantity * Negotiated_Price) AS Total_Spend,
        SUM(
            CASE
                WHEN Order_Status <> 'Delivered'
                THEN Quantity * Negotiated_Price
                ELSE 0
            END
        ) AS Incomplete_Order_Value
    FROM ProcurementAnalytics.procurement
    GROUP BY Supplier
)

SELECT
    Supplier,
    ROUND(Total_Spend, 2) AS Total_Spend,
    ROUND(Incomplete_Order_Value, 2) AS Incomplete_Order_Value,
    ROUND(
        Incomplete_Order_Value / Total_Spend * 100,
        2
    ) AS Incomplete_Value_Percentage
FROM supplier_exposure
ORDER BY Incomplete_Value_Percentage DESC;

-- Q22 What percentage of each category's procurement spend comes from each supplier?

WITH supplier_category_spend AS (
    SELECT
        Item_Category,
        Supplier,
        SUM(Quantity * Negotiated_Price) AS Supplier_Spend
    FROM ProcurementAnalytics.procurement
    GROUP BY Item_Category, Supplier
)

SELECT
    Item_Category,
    Supplier,
    ROUND(Supplier_Spend, 2) AS Supplier_Spend,
    ROUND(
        Supplier_Spend /
        SUM(Supplier_Spend) OVER (PARTITION BY Item_Category) * 100,
        2
    ) AS Category_Spend_Share
FROM supplier_category_spend
ORDER BY Item_Category, Category_Spend_Share DESC;

-- Q23 Which suppliers should be prioritized for procurement performance review?

WITH supplier_metrics AS (
    SELECT
        Supplier,
        ROUND(AVG(Delivery_Days), 2) AS Avg_Delivery_Days,
        ROUND(
            SUM(Defective_Units) / SUM(Quantity) * 100,
            2
        ) AS Defect_Rate,
        ROUND(
            SUM(CASE WHEN Compliance = 'Yes' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*),
            2
        ) AS Compliance_Rate,
        ROUND(
            SUM(CASE WHEN Order_Status <> 'Delivered' THEN 1 ELSE 0 END)
            * 100.0 / COUNT(*),
            2
        ) AS Incomplete_Order_Rate
    FROM ProcurementAnalytics.procurement
    GROUP BY Supplier
)

SELECT
    Supplier,
    Avg_Delivery_Days,
    Defect_Rate,
    Compliance_Rate,
    Incomplete_Order_Rate,
    (
        CASE WHEN Avg_Delivery_Days > 20 THEN 1 ELSE 0 END +
        CASE WHEN Defect_Rate > 10 THEN 1 ELSE 0 END +
        CASE WHEN Compliance_Rate < 70 THEN 1 ELSE 0 END +
        CASE WHEN Incomplete_Order_Rate > 25 THEN 1 ELSE 0 END
    ) AS Risk_Flags
FROM supplier_metrics
ORDER BY Risk_Flags DESC;

-- Q24 Which suppliers have the highest purchase order cancellation rates?

SELECT
    Supplier,
    COUNT(*) AS Total_Orders,
    SUM(
        CASE
            WHEN Order_Status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS Cancelled_Orders,
    ROUND(
        SUM(
            CASE
                WHEN Order_Status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS Cancellation_Rate
FROM ProcurementAnalytics.procurement
GROUP BY Supplier
ORDER BY Cancellation_Rate DESC;

-- Are there any missing values in the key procurement fields?

SELECT
    SUM(PO_ID IS NULL) AS Missing_PO_ID,
    SUM(Supplier IS NULL) AS Missing_Supplier,
    SUM(Order_Date IS NULL) AS Missing_Order_Date,
    SUM(Delivery_Date IS NULL) AS Missing_Delivery_Date,
    SUM(Item_Category IS NULL) AS Missing_Category,
    SUM(Quantity IS NULL) AS Missing_Quantity,
    SUM(Unit_Price IS NULL) AS Missing_Unit_Price,
    SUM(Negotiated_Price IS NULL) AS Missing_Negotiated_Price
FROM ProcurementAnalytics.procurement;

-- What period does the procurement dataset cover?

SELECT
    MIN(Order_Date) AS Start_Date,
    MAX(Order_Date) AS End_Date
FROM ProcurementAnalytics.procurement;