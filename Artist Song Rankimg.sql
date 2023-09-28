-- Day 49 (Window Function & Subquery Practice Day6)

-- CASE 1: Top 2 Gross Spend on Products 
/*Assume you're given a table containing data on Amazon customers and their spending on products in different categorie, 
write a query to identify the top two highest-grossing products within each category in the year 2022. 
The output should include the category, product, and total spend.*/

WITH spend_cte AS
              (SELECT category, product, SUM(spend)AS gross_total,
                      DENSE_RANK() OVER(PARTITION BY category 
                      ORDER BY SUM(spend) DESC) AS gross_rank
              FROM product_spend
              WHERE YEAR(transaction_date) = 2022
              GROUP BY category,product)
SELECT category, product, gross_total
FROM spend_cte
WHERE gross_rank IN(1,2);

-- CASE 2: Artist Song Global Ranking
/*Assume there are three Spotify tables: artists, songs, and global_song_rank, which contain information about the artists, 
songs, and music charts, respectively. Write a query to find the top 5 artists whose songs appear most frequently in the 
Top 10 of the global_song_rank table. Display the top 5 artist names in ascending order, along with their song appearance ranking.
Assumptions:
If two or more artists have the same number of song appearances, they should be assigned the same ranking, and the rank numbers 
should be continuous (i.e. 1, 2, 2, 3, 4, 5). For instance, if both Ed Sheeran and Bad Bunny appear in the Top 10 five times, 
they should both be ranked 1st and the next artist should be ranked 2nd.*/

WITH artist_rank_cte AS
                      (SELECT a.artist_name,s.song_id, g.rank
                      FROM artists a 
                      JOIN songs s 
                      ON a.artist_id = s.artist_id
                      JOIN global_song_rank g 
                      ON s.song_id = g.song_id
                      WHERE g.rank <= 10),
app_count_cte AS 
              (SELECT artist_name, COUNT(*) AS no_of_app,
                      DENSE_RANK() OVER(ORDER BY COUNT(*) DESC) AS app_rank
                FROM artist_rank_cte
                GROUP BY artist_name)
SELECT artist_name, app_rank
FROM app_count_cte
WHERE app_rank <=5;