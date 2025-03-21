CREATE DATABASE Water_Analysis_Data;
USE Water_Analysis_Data;

SELECT *
FROM Water_Quality;

SELECT Potability, COUNT(*) AS Total_Count
FROM Water_Quality
GROUP BY Potability;

SELECT 
    Potability,
    AVG(pH) AS avg_pH,
    AVG(Hardness) AS avg_Hardness,
    AVG(Solids) AS avg_Solids,
    AVG(Chloramines) AS avg_Chloramines,
    AVG(Sulfate) AS avg_Sulfate,
    AVG(Conductivity) AS avg_Conductivity,
    AVG(Organic_Carbon) AS avg_Organic_Carbon,
    AVG(Trihalomethanes) AS avg_Trihalomethanes,
    AVG(Turbidity) AS avg_Turbidity
FROM water_quality
GROUP BY Potability;

SELECT 
    CASE 
        WHEN pH < 6.5 THEN 'Acidic'
        WHEN pH BETWEEN 6.5 AND 8.5 THEN 'Neutral'
        ELSE 'Alkaline'
    END AS pH_Category,
    COUNT(*) AS Count
FROM water_quality
GROUP BY pH_Category;

SELECT COUNT(*) AS Non_Potable_Unsafe_pH
FROM water_quality
WHERE Potability = 0 AND (pH < 6.5 OR pH > 8.5);

SELECT Potability, AVG(Solids) AS avg_TDS
FROM water_quality
GROUP BY Potability;

CREATE OR REPLACE VIEW water_quality_analysis_data AS
SELECT 

#pH Category
    CASE 
        WHEN pH < 6.5 THEN 'Acidic'
        WHEN pH BETWEEN 6.5 AND 8.5 THEN 'Neutral'
        ELSE 'Alkaline'
    END AS pH_Category,

    #Hardness Category
    CASE 
        WHEN Hardness < 100 THEN 'Soft Water (below 100)'
        WHEN Hardness BETWEEN 100 AND 200 THEN 'Moderately Hard (100 to 200)'
        ELSE 'Hard Water (above 200)'
    END AS Hardness_Category,

    # Potability Status
    CASE 
        WHEN Potability = 1 THEN 'Potable'
        ELSE 'Not Potable'
    END AS Potability_Status,

    #Count of potable & non-potable samples
    COUNT(*) OVER(PARTITION BY Potability) AS Total_Count,

    #Count of samples in each pH category
    COUNT(*) OVER(PARTITION BY 
        CASE 
            WHEN pH < 6.5 THEN 'Acidic'
            WHEN pH BETWEEN 6.5 AND 8.5 THEN 'Neutral'
            ELSE 'Alkaline'
        END) AS pH_Category_Count,

    #Count of unsafe pH in non-potable water
    SUM(CASE WHEN Potability = 0 AND (pH < 6.5 OR pH > 8.5) THEN 1 ELSE 0 END) 
    OVER() AS Non_Potable_Unsafe_pH,

    # Average TDS (Total Dissolved Solids) for Potability groups
    AVG(Solids) OVER(PARTITION BY Potability) AS avg_TDS

FROM water_quality;

show create view water_quality_Analysis_data;
