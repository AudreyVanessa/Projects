SELECT * from 
[PortfolioProject].[dbo].[product_emissions$]

/*checking total the carbon footprint per company*/

select company, carbon_footprint_pcf
from [PortfolioProject].[dbo].[product_emissions$]


/*check how carbon emissions have changed overtime*/

select year,
round(SUM(carbon_footprint_pcf),2) as Total_carbon_emissions
from [PortfolioProject].[dbo].[product_emissions$]
group by year
order by year;

/*which industry has the most carbon emissions*/

select industry_group,
round(SUM(carbon_footprint_pcf),2) as Total_carbon_emissions
from [PortfolioProject].[dbo].[product_emissions$]
group by industry_group
order by Total_carbon_emissions desc;

/*WHICH INDUSTRY HAS MADE SIGNIFICANT PROGRESS IN REDUCING EMISSION*/

WITH industry_yearly_emissions AS (
SELECT
	year,
	industry_group,
	SUM(carbon_footprint_pcf) AS total_carbon_footprint
	FROM
		[PortfolioProject].[dbo].[product_emissions$]
	GROUP BY 
		year,
		industry_group
),
--2. calculate the year percentage change in emissions for each
industry_pct_change AS (
	SELECT
	a.year,
	a.industry_group,
	a.total_carbon_footprint,
	((a.total_carbon_footprint - b.total_carbon_footprint) / b.total_carbon_footprint) * 100 AS pct_change
FROM
	industry_yearly_emissions a
JOIN
	industry_yearly_emissions b
ON
	a.industry_group = b.industry_group
	AND a.year = b.year + 1
)
--3.Identify the industry with significant reduction in emissions
SELECT
	year,
    industry_group,
    total_carbon_footprint,
    pct_change
FROM 
    industry_pct_change
WHERE 
    pct_change < -10
ORDER BY 
    industry_group, 
    year;

--REGIONAL DIFFERENCE IN EMISSION
--Step 1.calculate the total carbon footprint for each region
WITH regional_total_emissions AS(
	select
		country,
		SUM(carbon_footprint_pcf) AS total_carbon_footprint
	FROM [PortfolioProject].[dbo].[product_emissions$]
	GROUP BY
	country
	),

-- Step 2: Calculate the average carbon footprint per product for each region

regional_avg_emissions AS (
select
	country,
	AVG(carbon_footprint_pcf) AS avg_carbon_footprint
FROM
	[PortfolioProject].[dbo].[product_emissions$]
GROUP BY
	country
)
-- Step 3: Combine the results and order by total emissions

select
	rte.country,
	rte.total_carbon_footprint,
	rae.avg_carbon_footprint
from
	regional_total_emissions rte
join
	regional_avg_emissions rae
on
	rte.country = rae.country
order by
	rte.total_carbon_footprint DESC;


--Specific product with the highest carbon emission
select TOP 1
	product_name,
	company,
	industry_group,
	country,
	year,
	carbon_footprint_pcf
FROM
	[PortfolioProject].[dbo].[product_emissions$]
	order by
	carbon_footprint_pcf DESC;

--how do emissions vary between types of products
-- Step 1: Calculate the total and average emissions for each product type
SELECT 
    product_name,
    COUNT(*) AS num_products,
    SUM(carbon_footprint_pcf) AS total_carbon_footprint,
    AVG(carbon_footprint_pcf) AS avg_carbon_footprint
FROM 
    [PortfolioProject].[dbo].[product_emissions$]
GROUP BY 
    product_name
ORDER BY 
    avg_carbon_footprint DESC;

-- Step 2: Calculate additional statistics for each product type (SQL Server)
SELECT 
    product_name,
    COUNT(*) AS num_products,
    SUM(carbon_footprint_pcf) AS total_carbon_footprint,
    AVG(carbon_footprint_pcf) AS avg_carbon_footprint,
    MAX(carbon_footprint_pcf) AS max_carbon_footprint,
    MIN(carbon_footprint_pcf) AS min_carbon_footprint,
    STDEV(carbon_footprint_pcf) AS stddev_carbon_footprint
FROM 
    [PortfolioProject].[dbo].[product_emissions$]
GROUP BY 
    product_name
ORDER BY 
    avg_carbon_footprint DESC;

	
