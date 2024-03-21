--------------------------------------------------------------------
---------------- Preprocessing Flavors -----------------------------
--------------------------------------------------------------------
SELECT * FROM chips;


-- let's find out how many flavors of chips are there
SELECT DISTINCT flavor 
FROM chips order by flavor;


-- split the flavors
-- find the first flavor value - up to the first |
DROP TABLE IF EXISTS get_first_flavor;
CREATE TABLE get_first_flavor AS 
SELECT itemID, chips_name, brand, flavor, 
CASE
	WHEN flavor like '%|%' THEN SUBSTR(flavor, 1, INSTR(flavor,'|')-1) 
	ELSE flavor 
END AS flavor1
FROM chips;

-- find the second flavor value
DROP TABLE IF EXISTS get_second_flavor;
CREATE TABLE get_second_flavor AS 
SELECT itemID, chips_name, brand, flavor, flavor1,
CASE
	WHEN flavor like '%|%|%' THEN SUBSTR(REPLACE(flavor, flavor1 || '|', ''), 1, INSTR(REPLACE(flavor, flavor1 || '|', ''), '|')-1)
	WHEN flavor like '%|%' THEN SUBSTR(flavor, INSTR(flavor, '|')+1, LENGTH(flavor))
	ELSE NULL
END AS flavor2
FROM get_first_flavor;

-- find the 3rd flavor value
DROP TABLE IF EXISTS get_third_flavor;
CREATE TABLE get_third_flavor AS 
SELECT itemID, chips_name, brand, flavor, flavor1, flavor2,
CASE
	WHEN flavor like '%|%|%' THEN REPLACE(flavor, flavor1 || '|' || flavor2 || '|', '')
	ELSE NULL 
END AS flavor3
FROM get_second_flavor;

select * from get_third_flavor gtf 

-- List all flavors together and remove duplicated with UNION 
-- this will give us a list of all possible flavor values
SELECT flavor1 AS flavor
FROM get_third_flavor 
UNION
SELECT flavor2 AS flavor
FROM get_third_flavor 
UNION
SELECT flavor3 AS flavor
FROM get_third_flavor;


-- 
--BBQ 1
--Beef 
--Cheese 2
--Citrus 3
--Jalapeno 4
--Meat 5
--Onion 6
--Original 7
--Pepper 8
--Sea Salt 9
--Seafood 10
--Soicy 
--Sour Cream 11
--Sour cream
--Spicy 12
--Sweet 13
--Tomato 14
--Vinegar 15

-- the code above was for exploration purposes. 
-- we don't need the temporary tables anymore.
DROP TABLE get_first_flavor;
DROP TABLE get_second_flavor;
DROP TABLE get_third_flavor;



-------------------------------
-- do one hot encoding
-------------------------------

-- we only need to fix the following values
-- Soicy -> Spicy 
-- Beef - > Meat 
-- Sour cream -> Sour Cream

SELECT * FROM chips;


-- Create the 0s and 1s for each flavor
DROP TABLE IF EXISTS chips_one_hot_encoding;
CREATE TABLE chips_one_hot_encoding AS
SELECT itemid, chips_name, brand, flavor, 
CASE 
	WHEN lower(flavor) LIKE '%bbq%' THEN 1
	ELSE 0
END AS bbq
FROM chips;

select sum(bbq) from chips_one_hot_encoding;

SELECT * FROM chips_one_hot_encoding; 

-- we'll talk about the two questions below.
-- How to encode when there's no flavor? What happens then?
-- How do you check that there are 1s in all columns?
