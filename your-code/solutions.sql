-- CHALLENGE 1:
-- Step 1: Calculate the royalty of each sale for each author and the advance for each author and publication
 SELECT tiau.au_id, ti.title_id, roy.sales_royalty, (ti.advance * tiau.royaltyper / 100) AS advance
 FROM titles AS ti
 JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
 JOIN (SELECT ti.title_id, (ti.price * sa.qty * (ti.royalty / 100) * (tiau.royaltyper / 100)) AS sales_royalty
		FROM titles AS ti
		JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
        JOIN sales AS sa ON ti.title_id = sa.title_id) AS roy ON ti.title_id = roy.title_id   
 GROUP BY tiau.au_id, ti.title_id;
 
 -- Step 2: Aggregate the total royalties for each title and author
SELECT rev.au_id, rev.title_id, (rev.sales_royalty + rev.advance) AS revenue
FROM	(SELECT tiau.au_id, ti.title_id, roy.sales_royalty, (ti.advance * tiau.royaltyper / 100) AS advance
		FROM titles AS ti
		JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
		JOIN 	(SELECT ti.title_id, (ti.price * sa.qty * (ti.royalty / 100) * (tiau.royaltyper / 100)) AS sales_royalty
				FROM titles AS ti
				JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
				JOIN sales AS sa ON ti.title_id = sa.title_id) AS roy ON ti.title_id = roy.title_id   
		GROUP BY tiau.au_id, ti.title_id) AS rev
 GROUP BY rev.au_id, rev.title_id;
 
 -- Step 3: Calculate the total profits of each author
 SELECT au.au_id, au.au_lname, au.au_fname, sum(trev.revenue) AS total_revenue
 FROM authors AS au
 JOIN	(SELECT rev.au_id, rev.title_id, (rev.sales_royalty + rev.advance) AS revenue
		FROM	(SELECT tiau.au_id, ti.title_id, roy.sales_royalty, (ti.advance * tiau.royaltyper / 100) AS advance
				FROM titles AS ti
				JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
				JOIN 	(SELECT ti.title_id, (ti.price * sa.qty * (ti.royalty / 100) * (tiau.royaltyper / 100)) AS sales_royalty
						FROM titles AS ti
						JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
						JOIN sales AS sa ON ti.title_id = sa.title_id) AS roy ON ti.title_id = roy.title_id   
				GROUP BY tiau.au_id, ti.title_id) AS rev
		GROUP BY rev.au_id, rev.title_id) AS trev ON trev.au_id = au.au_id
GROUP BY au.au_id
ORDER BY total_revenue DESC
LIMIT 3;


-- CHALLENGE 2:
-- Step 1: Create a temporary table with the result of Step 1 / Challenge 1
CREATE TEMPORARY TABLE revenue
SELECT tiau.au_id, ti.title_id, roy.sales_royalty, (ti.advance * tiau.royaltyper / 100) AS advance
 FROM titles AS ti
 JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
 JOIN (SELECT ti.title_id, (ti.price * sa.qty * (ti.royalty / 100) * (tiau.royaltyper / 100)) AS sales_royalty
		FROM titles AS ti
		JOIN titleauthor AS tiau ON ti.title_id = tiau.title_id
        JOIN sales AS sa ON ti.title_id = sa.title_id) AS roy ON ti.title_id = roy.title_id   
 GROUP BY tiau.au_id, ti.title_id;
 
-- Step 2: query the temporary table in the subsequent steps
CREATE TEMPORARY TABLE total_revenue
SELECT rev.au_id, rev.title_id, (rev.sales_royalty + rev.advance) AS revenue
FROM revenue AS rev
GROUP BY rev.au_id, rev.title_id;
 
 -- Step 3: Calculate the total profits of each author
SELECT au.au_id, au.au_lname, au.au_fname, sum(trev.revenue) AS total_revenue
FROM authors AS au
JOIN total_revenue AS trev ON trev.au_id = au.au_id
GROUP BY au.au_id
ORDER BY total_revenue DESC
LIMIT 3;


-- CHALLENGE 3: create a permanent table (most_profiting_authors) to hold the data about the most profiting authors. 
-- Note: the table was alreadt created in the original DB, so I am only altering it to add the values. 
INSERT INTO most_profiting_authors (au_id, profits)
	SELECT trev.au_id, sum(trev.revenue) AS total_revenue
	FROM total_revenue AS trev
	GROUP BY trev.au_id
	ORDER BY total_revenue DESC
	LIMIT 3;
