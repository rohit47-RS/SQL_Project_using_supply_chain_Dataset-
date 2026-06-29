-- ============================================================
--  MSSQL PROJECT: Supply Chain Analytics System
--  Dataset: 100 SKUs across Haircare, Skincare & Cosmetics
--  Includes: DB setup, Tables, Full Data & 25 Queries
-- ============================================================


-- ============================================================
-- SECTION 3: 25 ANALYTICAL QUERIES
-- ============================================================

-- ──────────────────────────────────────────────────────
-- Q1: Overview — row count and distinct values per key column
-- ──────────────────────────────────────────────────────
SELECT
    COUNT(*)                                    AS TotalSKUs,
    COUNT(DISTINCT ProductType)                 AS ProductTypes,
    COUNT(DISTINCT SupplierName)                AS Suppliers,
    COUNT(DISTINCT Location)                    AS Locations,
    COUNT(DISTINCT ShippingCarriers)            AS Carriers,
    COUNT(DISTINCT TransportationModes)         AS TransportModes,
    COUNT(DISTINCT Routes)                      AS Routes,
    COUNT(DISTINCT InspectionResults)           AS InspectionStatuses
FROM SupplyChain;

-- ──────────────────────────────────────────────────────
-- Q2: Revenue, units sold & avg price by product type
-- ──────────────────────────────────────────────────────
SELECT
    ProductType,
    COUNT(*)                        AS SKUCount,
    SUM(NumberOfProductsSold)       AS TotalUnitsSold,
    ROUND(SUM(RevenueGenerated),2)  AS TotalRevenue,
    ROUND(AVG(RevenueGenerated),2)  AS AvgRevenue,
    ROUND(AVG(Price),2)             AS AvgPrice,
    ROUND(MAX(RevenueGenerated),2)  AS MaxRevenue,
    ROUND(MIN(RevenueGenerated),2)  AS MinRevenue
FROM SupplyChain
GROUP BY ProductType
ORDER BY TotalRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q3: Top 10 SKUs by revenue generated
-- ──────────────────────────────────────────────────────
SELECT TOP 10
    SKU,
    ProductType,
    Price,
    NumberOfProductsSold,
    ROUND(RevenueGenerated,2) AS Revenue,
    SupplierName,
    Location
FROM SupplyChain
ORDER BY RevenueGenerated DESC;

-- ──────────────────────────────────────────────────────
-- Q4: Supplier performance — revenue, defects, lead times
-- ──────────────────────────────────────────────────────
SELECT
    SupplierName,
    COUNT(*)                              AS SKUsSupplied,
    ROUND(SUM(RevenueGenerated),2)        AS TotalRevenue,
    ROUND(AVG(DefectRates),4)             AS AvgDefectRate,
    ROUND(AVG(CAST(LeadTime AS FLOAT)),1) AS AvgLeadTimeDays,
    ROUND(AVG(ManufacturingCosts),2)      AS AvgMfgCost,
    ROUND(AVG(ProductionVolumes),0)       AS AvgProdVolume
FROM SupplyChain
GROUP BY SupplierName
ORDER BY TotalRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q5: City/location breakdown — revenue and SKU count
-- ──────────────────────────────────────────────────────
SELECT
    Location,
    COUNT(*)                         AS SKUCount,
    ROUND(SUM(RevenueGenerated),2)   AS TotalRevenue,
    ROUND(AVG(ManufacturingCosts),2) AS AvgMfgCost,
    ROUND(AVG(DefectRates),4)        AS AvgDefectRate,
    SUM(ProductionVolumes)           AS TotalProductionVolume
FROM SupplyChain
GROUP BY Location
ORDER BY TotalRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q6: Shipping carrier performance — cost, time, orders
-- ──────────────────────────────────────────────────────
SELECT
    ShippingCarriers,
    COUNT(*)                            AS TotalShipments,
    ROUND(AVG(ShippingCosts),2)         AS AvgShippingCost,
    ROUND(SUM(ShippingCosts),2)         AS TotalShippingCost,
    ROUND(AVG(CAST(ShippingTimes AS FLOAT)),1) AS AvgShippingDays,
    ROUND(SUM(RevenueGenerated),2)      AS RevenueHandled
FROM SupplyChain
GROUP BY ShippingCarriers
ORDER BY TotalShipments DESC;

-- ──────────────────────────────────────────────────────
-- Q7: Transportation mode analysis
-- ──────────────────────────────────────────────────────
SELECT
    TransportationModes,
    COUNT(*)                             AS SKUCount,
    ROUND(AVG(Costs),2)                  AS AvgTransportCost,
    ROUND(SUM(Costs),2)                  AS TotalTransportCost,
    ROUND(AVG(ShippingTimes),1)          AS AvgShippingTime,
    ROUND(AVG(DefectRates),4)            AS AvgDefectRate,
    ROUND(SUM(RevenueGenerated),2)       AS TotalRevenue
FROM SupplyChain
GROUP BY TransportationModes
ORDER BY TotalRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q8: Inspection result summary with defect statistics
-- ──────────────────────────────────────────────────────
SELECT
    InspectionResults,
    COUNT(*)                          AS SKUCount,
    ROUND(AVG(DefectRates),4)         AS AvgDefectRate,
    ROUND(MIN(DefectRates),4)         AS MinDefectRate,
    ROUND(MAX(DefectRates),4)         AS MaxDefectRate,
    ROUND(SUM(RevenueGenerated),2)    AS TotalRevenue,
    ROUND(AVG(ManufacturingCosts),2)  AS AvgMfgCost
FROM SupplyChain
GROUP BY InspectionResults
ORDER BY SKUCount DESC;

-- ──────────────────────────────────────────────────────
-- Q9: SKUs that FAILED inspection — ranked by defect rate
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    SupplierName,
    Location,
    ROUND(DefectRates,4)              AS DefectRate,
    ROUND(RevenueGenerated,2)         AS Revenue,
    ROUND(ManufacturingCosts,2)       AS MfgCost,
    TransportationModes
FROM SupplyChain
WHERE InspectionResults = 'Fail'
ORDER BY DefectRates DESC;

-- ──────────────────────────────────────────────────────
-- Q10: Stock level health check — overstocked vs understocked
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    StockLevels,
    OrderQuantities,
    NumberOfProductsSold,
    CASE
        WHEN StockLevels = 0              THEN 'Out of Stock'
        WHEN StockLevels < 10             THEN 'Critical Low'
        WHEN StockLevels BETWEEN 10 AND 30 THEN 'Low'
        WHEN StockLevels BETWEEN 31 AND 70 THEN 'Healthy'
        ELSE 'Overstocked'
    END AS StockStatus,
    ROUND(RevenueGenerated,2)          AS Revenue
FROM SupplyChain
ORDER BY StockLevels ASC;

-- ──────────────────────────────────────────────────────
-- Q11: Route efficiency — cost vs revenue by route
-- ──────────────────────────────────────────────────────
SELECT
    Routes,
    COUNT(*)                             AS SKUCount,
    ROUND(SUM(Costs),2)                  AS TotalTransportCost,
    ROUND(AVG(Costs),2)                  AS AvgTransportCost,
    ROUND(SUM(RevenueGenerated),2)       AS TotalRevenue,
    ROUND(SUM(RevenueGenerated) / NULLIF(SUM(Costs),0), 2) AS RevenueToCostratio
FROM SupplyChain
GROUP BY Routes
ORDER BY RevenueToCostratio DESC;

-- ──────────────────────────────────────────────────────
-- Q12: Customer demographics — who buys what
-- ──────────────────────────────────────────────────────
SELECT
    CustomerDemographics,
    ProductType,
    COUNT(*)                         AS SKUCount,
    SUM(NumberOfProductsSold)        AS UnitsSold,
    ROUND(SUM(RevenueGenerated),2)   AS TotalRevenue,
    ROUND(AVG(Price),2)              AS AvgPrice
FROM SupplyChain
GROUP BY CustomerDemographics, ProductType
ORDER BY CustomerDemographics, TotalRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q13: Manufacturing cost vs revenue profitability view
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    ROUND(Price,2)                                          AS UnitPrice,
    ROUND(ManufacturingCosts,2)                             AS MfgCost,
    ROUND(RevenueGenerated,2)                               AS Revenue,
    ROUND(RevenueGenerated - ManufacturingCosts,2)          AS GrossProfit,
    ROUND((RevenueGenerated - ManufacturingCosts)
          / NULLIF(RevenueGenerated,0) * 100, 2)            AS ProfitMarginPct
FROM SupplyChain
ORDER BY ProfitMarginPct DESC;

-- ──────────────────────────────────────────────────────
-- Q14: Lead time analysis by supplier and location
-- ──────────────────────────────────────────────────────
SELECT
    SupplierName,
    Location,
    COUNT(*)                              AS SKUCount,
    ROUND(AVG(CAST(LeadTime AS FLOAT)),1) AS AvgLeadDays,
    MIN(LeadTime)                         AS MinLeadDays,
    MAX(LeadTime)                         AS MaxLeadDays,
    ROUND(AVG(ManufacturingLeadTime),1)   AS AvgMfgLeadDays
FROM SupplyChain
GROUP BY SupplierName, Location
ORDER BY AvgLeadDays DESC;

-- ──────────────────────────────────────────────────────
-- Q15: Rank all SKUs by revenue using DENSE_RANK
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    ROUND(RevenueGenerated,2)   AS Revenue,
    ROUND(Price,2)              AS Price,
    SupplierName,
    DENSE_RANK() OVER (ORDER BY RevenueGenerated DESC)            AS OverallRank,
    DENSE_RANK() OVER (PARTITION BY ProductType ORDER BY RevenueGenerated DESC) AS RankInCategory
FROM SupplyChain
ORDER BY OverallRank;

-- ──────────────────────────────────────────────────────
-- Q16: Moving average of revenue ordered by SKU number
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    ROUND(RevenueGenerated,2) AS Revenue,
    ROUND(AVG(RevenueGenerated) OVER (
        ORDER BY ID
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ),2) AS MovingAvg5SKU
FROM SupplyChain
ORDER BY ID;

-- ──────────────────────────────────────────────────────
-- Q17: Defect rate percentile buckets
-- ──────────────────────────────────────────────────────
SELECT
    CASE
        WHEN DefectRates < 1.0 THEN '0–1% (Excellent)'
        WHEN DefectRates < 2.0 THEN '1–2% (Good)'
        WHEN DefectRates < 3.0 THEN '2–3% (Acceptable)'
        WHEN DefectRates < 4.0 THEN '3–4% (Concerning)'
        ELSE                        '4%+ (Critical)'
    END AS DefectBucket,
    COUNT(*)                          AS SKUCount,
    ROUND(AVG(ManufacturingCosts),2)  AS AvgMfgCost,
    ROUND(SUM(RevenueGenerated),2)    AS TotalRevenue
FROM SupplyChain
GROUP BY
    CASE
        WHEN DefectRates < 1.0 THEN '0–1% (Excellent)'
        WHEN DefectRates < 2.0 THEN '1–2% (Good)'
        WHEN DefectRates < 3.0 THEN '2–3% (Acceptable)'
        WHEN DefectRates < 4.0 THEN '3–4% (Concerning)'
        ELSE                        '4%+ (Critical)'
    END
ORDER BY MIN(DefectRates);

-- ──────────────────────────────────────────────────────
-- Q18: Availability vs stock level discrepancy alert
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    Availability          AS AvailabilityPct,
    StockLevels,
    OrderQuantities,
    NumberOfProductsSold,
    ABS(Availability - StockLevels) AS DiscrepancyScore
FROM SupplyChain
WHERE ABS(Availability - StockLevels) > 30
ORDER BY DiscrepancyScore DESC;

-- ──────────────────────────────────────────────────────
-- Q19: Supplier vs defect rate — flag high-risk suppliers
-- ──────────────────────────────────────────────────────
WITH SupplierDefect AS (
    SELECT
        SupplierName,
        ROUND(AVG(DefectRates),4) AS AvgDefect,
        COUNT(*)                  AS SKUCount,
        SUM(CASE WHEN InspectionResults = 'Fail' THEN 1 ELSE 0 END) AS FailCount
    FROM SupplyChain
    GROUP BY SupplierName
)
SELECT
    SupplierName,
    SKUCount,
    AvgDefect,
    FailCount,
    ROUND(CAST(FailCount AS FLOAT)/SKUCount*100,1) AS FailRatePct,
    CASE
        WHEN AvgDefect >= 3.0 THEN 'HIGH RISK'
        WHEN AvgDefect >= 2.0 THEN 'MODERATE'
        ELSE 'LOW RISK'
    END AS RiskLevel
FROM SupplierDefect
ORDER BY AvgDefect DESC;

-- ──────────────────────────────────────────────────────
-- Q20: Shipping cost per unit of revenue (cost efficiency)
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    ShippingCarriers,
    TransportationModes,
    Routes,
    ROUND(ShippingCosts,2)                                      AS ShippingCost,
    ROUND(Costs,2)                                              AS TransportCost,
    ROUND(RevenueGenerated,2)                                   AS Revenue,
    ROUND((ShippingCosts + Costs) / NULLIF(RevenueGenerated,0) * 100, 2) AS LogisticsCostPct
FROM SupplyChain
ORDER BY LogisticsCostPct DESC;

-- ──────────────────────────────────────────────────────
-- Q21: Production volume vs units sold (over/under production)
-- ──────────────────────────────────────────────────────
SELECT
    SKU,
    ProductType,
    SupplierName,
    ProductionVolumes,
    NumberOfProductsSold,
    ProductionVolumes - NumberOfProductsSold             AS Surplus,
    ROUND(CAST(NumberOfProductsSold AS FLOAT)
          / NULLIF(ProductionVolumes,0) * 100, 1)        AS SellThroughPct,
    CASE
        WHEN ProductionVolumes < NumberOfProductsSold    THEN 'UNDERPRODUCED'
        WHEN ProductionVolumes > NumberOfProductsSold*2  THEN 'OVERPRODUCED'
        ELSE 'BALANCED'
    END AS ProductionStatus
FROM SupplyChain
ORDER BY SellThroughPct DESC;

-- ──────────────────────────────────────────────────────
-- Q22: Cross-tab — product type × transportation mode count
-- ──────────────────────────────────────────────────────
SELECT
    ProductType,
    SUM(CASE WHEN TransportationModes = 'Air'  THEN 1 ELSE 0 END) AS Air,
    SUM(CASE WHEN TransportationModes = 'Road' THEN 1 ELSE 0 END) AS Road,
    SUM(CASE WHEN TransportationModes = 'Rail' THEN 1 ELSE 0 END) AS Rail,
    SUM(CASE WHEN TransportationModes = 'Sea'  THEN 1 ELSE 0 END) AS Sea,
    COUNT(*) AS Total
FROM SupplyChain
GROUP BY ProductType
ORDER BY Total DESC;

-- ──────────────────────────────────────────────────────
-- Q23: CTE — top revenue SKU per supplier
-- ──────────────────────────────────────────────────────
WITH RankedBySupplier AS (
    SELECT
        SupplierName,
        SKU,
        ProductType,
        ROUND(RevenueGenerated,2) AS Revenue,
        RANK() OVER (PARTITION BY SupplierName ORDER BY RevenueGenerated DESC) AS Rnk
    FROM SupplyChain
)
SELECT
    SupplierName,
    SKU                AS TopSKU,
    ProductType,
    Revenue            AS TopRevenue
FROM RankedBySupplier
WHERE Rnk = 1
ORDER BY TopRevenue DESC;

-- ──────────────────────────────────────────────────────
-- Q24: Full logistics cost breakdown per product type
-- ──────────────────────────────────────────────────────
SELECT
    ProductType,
    ROUND(SUM(RevenueGenerated),2)                AS TotalRevenue,
    ROUND(SUM(ManufacturingCosts),2)              AS TotalMfgCost,
    ROUND(SUM(ShippingCosts),2)                   AS TotalShippingCost,
    ROUND(SUM(Costs),2)                           AS TotalTransportCost,
    ROUND(SUM(ManufacturingCosts + ShippingCosts + Costs),2) AS TotalCost,
    ROUND(SUM(RevenueGenerated)
          - SUM(ManufacturingCosts + ShippingCosts + Costs),2) AS EstimatedNetProfit,
    ROUND((SUM(RevenueGenerated) - SUM(ManufacturingCosts + ShippingCosts + Costs))
          / NULLIF(SUM(RevenueGenerated),0) * 100, 2)          AS NetMarginPct
FROM SupplyChain
GROUP BY ProductType
ORDER BY EstimatedNetProfit DESC;

-- ──────────────────────────────────────────────────────
-- Q25: Executive dashboard summary
-- ──────────────────────────────────────────────────────
SELECT
    (SELECT COUNT(*)                FROM SupplyChain)                          AS TotalSKUs,
    (SELECT ROUND(SUM(RevenueGenerated),2) FROM SupplyChain)                   AS TotalRevenue,
    (SELECT SUM(NumberOfProductsSold) FROM SupplyChain)                        AS TotalUnitsSold,
    (SELECT ROUND(AVG(DefectRates),4)   FROM SupplyChain)                      AS OverallAvgDefectRate,
    (SELECT COUNT(*) FROM SupplyChain WHERE InspectionResults = 'Pass')        AS PassedInspections,
    (SELECT COUNT(*) FROM SupplyChain WHERE InspectionResults = 'Fail')        AS FailedInspections,
    (SELECT COUNT(*) FROM SupplyChain WHERE InspectionResults = 'Pending')     AS PendingInspections,
    (SELECT ROUND(AVG(CAST(LeadTime AS FLOAT)),1) FROM SupplyChain)            AS AvgLeadTimeDays,
    (SELECT ROUND(SUM(Costs + ShippingCosts),2) FROM SupplyChain)              AS TotalLogisticsCost,
    (SELECT TOP 1 SupplierName FROM SupplyChain
        GROUP BY SupplierName ORDER BY SUM(RevenueGenerated) DESC)             AS TopSupplier,
    (SELECT TOP 1 Location FROM SupplyChain
        GROUP BY Location ORDER BY SUM(RevenueGenerated) DESC)                 AS TopLocation,
    (SELECT TOP 1 TransportationModes FROM SupplyChain
        GROUP BY TransportationModes ORDER BY COUNT(*) DESC)                   AS MostUsedTransportMode,
    (SELECT TOP 1 SKU FROM SupplyChain ORDER BY RevenueGenerated DESC)         AS HighestRevenueSKU,
    (SELECT TOP 1 SKU FROM SupplyChain ORDER BY DefectRates DESC)              AS HighestDefectSKU;

GO
-- ============================================================
-- END OF SUPPLY CHAIN PROJECT
-- ============================================================
