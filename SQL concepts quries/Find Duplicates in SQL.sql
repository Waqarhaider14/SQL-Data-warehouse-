-- Find Duplicates

WITH custom_cte AS (select *, ROW_NUMBER() OVER ( PARTITION BY trucktype) AS rn FROM dw.dimtruck )
SELECT * FROM custom_cte where rn > 1;



/*
-- Delete Duplicates using CTE 

WITH custom_cte AS (select *, ROW_NUMBER() OVER ( PARTITION BY trucktype) AS rn FROM dw.dimtruck )
DELETE FROM custom_cte where rn > 1;

*/


/*
-- Find and delete duplicates using nested select

DELETE FROM dw.dimtruck
WHERE truckid IN (
SELECT truckid
	FROM (
			SELECT truckid, ROW_NUMBER() OVER (PARTITION BY trucktype) AS rn FROM dw.dimtruck ) 
	
	WHERE rn >1
);
*/