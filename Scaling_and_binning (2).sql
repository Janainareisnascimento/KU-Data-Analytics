
-- Let us explore the database a little bit
SELECT * FROM chips;

SELECT * FROM customers;

SELECT * FROM purchases;

-- we should know how many products and how many customers we're dealing with
SELECT COUNT(*) FROM chips;

SELECT COUNT(*) FROM customers;

-- table purchases has 275*1500 rows because there's a "relationship" for every
-- customer with every chips
-- in the project datasets this is not the case you may have to add rows 
-- to define every customer-item interaction
SELECT COUNT(*) FROM purchases; 

-- what is the minimum that anyone bought of any flavor
SELECT MIN(bought) FROM purchases;

-- what is the maximum
SELECT MAX(bought) FROM purchases;

-- how many customer-item interactions are there
-- where a person actually bought a chips
SELECT COUNT(*) 
FROM purchases
WHERE bought > 0;

-- how many flavors of chips did each customer buy
SELECT cid, COUNT(itemid) AS count_flavors 
FROM purchases
WHERE bought > 0
GROUP BY cid
ORDER BY count_flavors DESC;

-- scale the sales

-- see how many different values there are for number of bags bought of a given flavor
SELECT DISTINCT bought 
FROM purchases 
ORDER BY bought;

---------------------------------------------------
-------------- Percentage scaling -----------------
---------------------------------------------------

-- find the total number of chips any customer bought last year
DROP TABLE IF EXISTS purchases_per_customer; 
CREATE TABLE IF NOT EXISTS purchases_per_customer AS
SELECT cid, SUM(bought) AS total_bought
FROM purchases
GROUP BY cid;

SELECT * FROM purchases_per_customer;


-- add total_bought to the individual purchases
DROP TABLE IF EXISTS combined; 
CREATE TABLE IF NOT EXISTS combined AS
SELECT p.cid, p.itemid, p.bought, ppc.total_bought
FROM purchases p
LEFT JOIN purchases_per_customer ppc
ON p.cid = ppc.cid;

SELECT * FROM combined;

-- sidenote about dividing two integers. In any (or at least most) languages, when you divide
-- two integers you get back an integer even though the correct answer may be decimal
SELECT 2/5 FROM chips;

-- to avoid the problem you need to force at least one of the terms to be a float
SELECT 2.0/5 FROM chips;

-- when the values come from a table column we can't just add the decimal point and zero
-- there are other ways to do it

-- the lazy way - multiply one of them by 1.0
SELECT 2*1.0/5 FROM chips;

-- the better way - use casting
SELECT CAST(2 AS FLOAT)/5 FROM chips;

-- drop table normalized_purchases;
DROP TABLE IF EXISTS scaled_purchases;
CREATE TABLE IF NOT EXISTS scaled_purchases AS
SELECT cid, itemid, bought, total_bought, CAST(bought AS FLOAT)/total_bought AS scaled_bought
FROM combined;

-- this is showing the "lazy" way
SELECT cid, itemid, bought, total_bought, bought*1.0/total_bought AS scaled_bought
FROM combined;

SELECT * FROM scaled_purchases; 

--------------------------------------------
--------------  BINNING --------------------
--------------------------------------------
DROP TABLE IF EXISTS purchases_to_rating;
CREATE TABLE purchases_to_rating AS
SELECT cid, itemid, bought, total_bought, scaled_bought, 
CASE
	WHEN scaled_bought*100 < 0.2 THEN 1 
	WHEN scaled_bought*100 < 0.4 THEN 2 -- between 0.2 and 0.4
	WHEN scaled_bought*100 < 0.6 THEN 3 -- WHEN scaled_bought >= 0.4 AND scaled_bought < 0.6
	WHEN scaled_bought*100 < 0.8 THEN 4
	WHEN scaled_bought*100 <= 1 THEN 5
	ELSE NULL
END AS rating
FROM scaled_purchases;

SELECT * from purchases_to_rating;

-- with the previous query if a person bought 0 of a certain flavor it is implied 
-- that they didn't like it because it's in bin 1-star. However, it is possible
-- that they have never tried it and in reality we don't know whether they like it or not.
-- perhaps it will be better to separate these cases so they don't confuse our model.
DROP TABLE IF EXISTS purchases_to_rating;
CREATE TABLE purchases_to_rating AS
SELECT cid, itemid, bought, scaled_bought, 
CASE
	WHEN scaled_bought*100 = 0 THEN 0 -- or NULL
	WHEN scaled_bought*100 < 0.2 THEN 1
	WHEN scaled_bought*100 < 0.4 THEN 2
	WHEN scaled_bought*100 < 0.6 THEN 3
	WHEN scaled_bought*100 < 0.8 THEN 4
	WHEN scaled_bought*100 <= 1 THEN 5
	ELSE NULL
END AS rating
FROM scaled_purchases;
	
SELECT * FROM purchases_to_rating;
SELECT * FROM chips_one_hot_encoding cohe ;

--DROP TABLE IF EXISTS purchases_per_customer; 
--DROP TABLE IF EXISTS combined;
--DROP TABLE IF EXISTS scaled_purchases;
--DROP TABLE IF EXISTS purchases_to_rating;

--Exercise
-- Replace the percentage scaling with min-max scaling.

 
