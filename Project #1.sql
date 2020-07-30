################################################################################
# Creating View
################################################################################

CREATE VIEW forestation AS (
SELECT l.country_code,
       l.country_name,
       l.year,
       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
       f.forest_area_sqkm AS forest_area_sqkm,
       r.region AS region,
       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost,
       ((LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) - (forest_area_sqkm))/LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year))*100 percent_forest_lost
FROM land_area l
JOIN forest_area f
ON l.country_code = f.country_code AND l.year = f.year
JOIN regions r
ON l.country_code = r.country_code
WHERE l.year = '1990' OR l.year = '2016'
ORDER BY 2, 3)

################################################################################
# Part 1
################################################################################

'''
a. What was the total forest area (in sq km) of the world in 1990?
Please keep in mind that you can use the country record denoted as
“World" in the region table.
'''

SELECT r.region, f.year, f.forest_area_sqkm
FROM regions r
JOIN forest_area f
ON r.country_code = f.country_code
WHERE r.region = 'World' AND f.year = '1990'

"""
b. What was the total forest area (in sq km) of the world in 2016? Please keep
in mind that you can use the country record in the table is denoted as “World.”
"""

SELECT r.region, f.year, f.forest_area_sqkm
FROM regions r
JOIN forest_area f
ON r.country_code = f.country_code
WHERE r.region = 'World' AND f.year = '2016'

"""
c. What was the change (in sq km) in the forest area of the world from 1990 to 2016?
"""

WITH table1 AS (SELECT r.region, f.year, f.forest_area_sqkm  area_1990
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '1990'),

	 table2 AS (SELECT r.region, f.year, f.forest_area_sqkm area_2016
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '2016')

SELECT (table1.area_1990 - table2.area_2016) AS forest_loss_1990_to_2016
FROM table1
JOIN table2
ON table1.region = table2.region

"""
d. What was the percent change in forest area of the world between 1990 and 2016?
"""

WITH table1 AS (SELECT r.region, f.year, f.forest_area_sqkm  area_1990
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '1990'),

	 table2 AS (SELECT r.region, f.year, f.forest_area_sqkm area_2016
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '2016')

SELECT (100-((table2.area_2016 / table1.area_1990)*100)) AS forest_loss_1990_to_2016
FROM table1
JOIN table2
ON table1.region = table2.region

"""
e. If you compare the amount of forest area lost between 1990 and 2016,
to which country's total area in 2016 is it closest to?
"""
# tried this method and it didnt work
WITH table1 AS (SELECT r.country_code, r.region, f.year, f.forest_area_sqkm  area_1990
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '1990'),

	 table2 AS (SELECT r.country_code, r.region, f.year, f.forest_area_sqkm area_2016
                FROM regions r
                JOIN forest_area f
                ON r.country_code = f.country_code
                WHERE r.region = 'World' AND f.year = '2016')

SELECT DISTINCT l.country_name, l.total_area_sq_mi*2.59 total_area_sqkm, (table1.area_1990 - table2.area_2016) AS forest_loss_1990_to_2016
FROM land_area l
JOIN table1
ON l.country_code = table1.country_code
JOIN table2
ON l.country_code = table2.country_code
WHERE l.total_area_sq_mi*2.59 >= table1.area_1990 - table2.area_2016
ORDER BY 2

# less than mongolia
SELECT DISTINCT l.country_name, l.total_area_sq_mi*2.59 total_area_sqkm
FROM land_area l
WHERE l.total_area_sq_mi*2.59 >= 1300000
ORDER BY 2

# greater than peru
SELECT DISTINCT l.country_name, l.total_area_sq_mi*2.59 total_area_sqkm
FROM land_area l
WHERE l.total_area_sq_mi*2.59 <= 1300000
ORDER BY 2 DESC

################################################################################
# Part 2
################################################################################

'''
a. What was the percent forest of the entire world in 2016? Which region had
the HIGHEST percent forest in 2016, and which had the LOWEST, to 2 decimal places?
'''

# percent forestation of the world in 2016

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.56 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.56))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT percent_forested
FROM table1
WHERE year = '2016' AND country_name = 'World'

# highest forested region

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, percent_forested
FROM table1
WHERE percent_forested = (WITH table1 AS (SELECT l.country_code,
                                                   l.country_name,
                                                   l.year,
                                                   l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                                                   f.forest_area_sqkm forest_area_sqkm,
                                                   r.region region,
                                                   (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                                                   forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                                            FROM land_area l
                                            JOIN forest_area f
                                            ON l.country_code = f.country_code AND l.year = f.year
                                            JOIN regions r
                                            ON l.country_code = r.country_code
                                            WHERE l.year = '1990' OR l.year = '2016'
                                            ORDER BY 2, 3)

                            SELECT MAX(percent_forested)
                            FROM table1
                            WHERE year = '2016')

# least forested region

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, percent_forested
FROM table1
WHERE percent_forested = (WITH table1 AS (SELECT l.country_code,
                                                   l.country_name,
                                                   l.year,
                                                   l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                                                   f.forest_area_sqkm forest_area_sqkm,
                                                   r.region region,
                                                   (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                                                   forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                                            FROM land_area l
                                            JOIN forest_area f
                                            ON l.country_code = f.country_code AND l.year = f.year
                                            JOIN regions r
                                            ON l.country_code = r.country_code
                                            WHERE l.year = '1990' OR l.year = '2016'
                                            ORDER BY 2, 3)

                            SELECT MIN(percent_forested)
                            FROM table1
                            WHERE year = '2016')

'''
b. What was the percent forest of the entire world in 1990? Which region had the
 HIGHEST percent forest in 1990, and which had the LOWEST, to 2 decimal places?
'''

# percent forestation of the world in 1990

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.56 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.56))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT percent_forested
FROM table1
WHERE year = '1990' AND country_name = 'World'

# regional percent forested

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, year, AVG(percent_forested) region_percent_forested
FROM table1
GROUP BY 1, 2
ORDER BY 2, 1

'''
c. Based on the table you created, which regions of the world DECREASED in
forest area from 1990 to 2016?
'''

# regional percent forest per year

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, year, AVG(percent_forested) region_percent_forested
FROM table1
GROUP BY 1, 2
ORDER BY 2, 1

# regional forest area lost

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, SUM(forest_area_lost)
FROM table1
GROUP BY 1
ORDER BY 1

# regional forest lost in 1990 and 2016 for sub saharan africa

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, year, AVG(percent_forested) region_percent_forested
FROM table1
WHERE region = 'Sub-Saharan Africa'
GROUP BY 1,2
ORDER BY 1

# regional forest lost in 1990 and 2016 for latin america and carribbean

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT region, year, AVG(percent_forested) region_percent_forested
FROM table1
WHERE region = 'Latin America & Caribbean'
GROUP BY 1,2
ORDER BY 1

################################################################################
# Part 3
################################################################################

'''
a. Which 5 countries saw the largest amount decrease in forest area from 1990
to 2016? What was the difference in forest area for each?
'''

# 5 countries with largest decrease in forest area from 1990 to 2016

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.56 AS total_area_sqkm,
                       f.forest_area_sqkm forest_area_sqkm,
                       r.region region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.56))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT country_name, region, SUM(forest_area_lost)
FROM table1
WHERE country_name != 'World'
GROUP BY 1, 2
ORDER BY 3 ASC
LIMIT  5

'''
b. Which 5 countries saw the largest percent decrease in forest area from 1990
to 2016? What was the percent change to 2 decimal places for each?
'''

# top 5 countries with largest percent decrease in forest from 1990 to 2016

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm AS forest_area_sqkm,
                       r.region AS region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost,
                       ((LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) - (forest_area_sqkm))/LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year))*100 percent_forest_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT country_name, region, percent_forest_lost, percent_forest_lost2
FROM table1
WHERE country_name != 'World'
ORDER BY 3
LIMIT 5

'''
c. If countries were grouped by percent forestation in quartiles, which group
had the most countries in it in 2016?
'''

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm AS forest_area_sqkm,
                       r.region AS region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost,
                       ((LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) - (forest_area_sqkm))/LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year))*100 percent_forest_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT COUNT(*), CASE WHEN percent_forested >= 0 AND percent_forested <=25 THEN 1
                      WHEN percent_forested > 25 AND percent_forested <=50 THEN 2
                      WHEN percent_forested > 50 AND percent_forested <=75 THEN 3
                      WHEN percent_forested > 75 AND percent_forested <=100 THEN 4
                      ELSE NULL END AS quartile
FROM table1
WHERE country_name != 'World' AND year = 2016
GROUP BY 2


'''
d. List all of the countries that were in the 4th quartile
(percent forest > 75%) in 2016.
'''

SELECT country_name, region, percent_forested
FROM(
WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.59 AS total_area_sqkm,
                       f.forest_area_sqkm AS forest_area_sqkm,
                       r.region AS region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.59))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost,
                       ((LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) - (forest_area_sqkm))/LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year))*100 percent_forest_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT country_name, region, percent_forested, CASE WHEN percent_forested <= 25 THEN 1
                      WHEN percent_forested > 25 AND percent_forested <=50 THEN 2
                      WHEN percent_forested > 50 AND percent_forested <=75 THEN 3
                      WHEN percent_forested > 75 AND percent_forested <=100 THEN 4
                      ELSE NULL END AS quartile
FROM table1
WHERE country_name != 'World' AND year = 2016)t1
WHERE quartile = 4
ORDER BY 3 DESC

'''
e. How many countries had a percent forestation higher than the
United States in 2016?
'''

# number of countries with percent forestation higher than the US

WITH table1 AS (SELECT l.country_code,
                       l.country_name,
                       l.year,
                       l.total_area_sq_mi * 2.56 AS total_area_sqkm,
                       f.forest_area_sqkm AS forest_area_sqkm,
                       r.region AS region,
                       (f.forest_area_sqkm/(l.total_area_sq_mi * 2.56))*100 AS percent_forested,
                       forest_area_sqkm - LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) AS forest_area_lost,
                       ((LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year) - (forest_area_sqkm))/LAG(forest_area_sqkm) OVER(PARTITION BY l.country_name ORDER BY l.year))*100 percent_forest_lost
                FROM land_area l
                JOIN forest_area f
                ON l.country_code = f.country_code AND l.year = f.year
                JOIN regions r
                ON l.country_code = r.country_code
                WHERE l.year = '1990' OR l.year = '2016'
                ORDER BY 2, 3)

SELECT COUNT(country_name)
FROM table1
WHERE country_name != 'World' AND year = 2016 AND percent_forested > (SELECT percent_forested
                                                                      FROM table1
                                                                      WHERE country_name = 'United States' AND year = 2016)
ORDER BY 1
