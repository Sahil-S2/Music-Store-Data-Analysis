USE MUSIC_STORE_DATA;

SELECT * FROM ALBUM;
SELECT * FROM ALBUM2;
SELECT * FROM ARTIST;
SELECT * FROM CUSTOMER;
SELECT * FROM EMPLOYEE;
SELECT * FROM GENRE;
SELECT * FROM INVOICE;
SELECT * FROM INVOICE_LINE;
SELECT * FROM MEDIA_TYPE;
SELECT * FROM PLAYLIST;
SELECT * FROM PLAYLIST_TRACK;
SELECT * FROM TRACK;



-- 1. Who is the senior most employee based on job title? 

SELECT FIRST_NAME,
       LAST_NAME,
       TITLE
FROM EMPLOYEE
WHERE LEVELS =
    (SELECT TOP 1 LEVELS
     FROM EMPLOYEE
     ORDER BY LEVELS DESC);



-- 2. Which countries have the most Invoices? 

SELECT TOP 1 BILLING_COUNTRY AS TOP_BILLING_COUNTRY,
           COUNT(*) AS NO_OF_BILLS
FROM INVOICE
GROUP BY BILLING_COUNTRY
ORDER BY NO_OF_BILLS DESC;



-- 3. What are top 3 values of total invoice?

SELECT TOP 3 TOTAL
FROM INVOICE
ORDER BY TOTAL DESC;



-- 4. Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice 
-- totals 

SELECT TOP 1 BILLING_CITY,
           ROUND(SUM(TOTAL), 2) AS TOTAL_INVOICE_CITY
FROM INVOICE
GROUP BY BILLING_CITY
ORDER BY TOTAL_INVOICE_CITY DESC;




-- 5. Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money 


SELECT TOP 1 CUSTOMER.FIRST_NAME,
           CUSTOMER.LAST_NAME,
           INVOICE.CUSTOMER_ID,
           ROUND(SUM(TOTAL), 2) AS TOTAL_INVOICE
FROM INVOICE
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY INVOICE.CUSTOMER_ID,
         CUSTOMER.FIRST_NAME,
         CUSTOMER.LAST_NAME
ORDER BY TOTAL_INVOICE DESC;



-- 6. Write query to return the email, first name, last name, & Genre of all Rock Music 
-- listeners. Return your list ordered alphabetically by email starting with A.


SELECT CUSTOMER.FIRST_NAME + ' ' + CUSTOMER.LAST_NAME AS FULL_NAME,
       CUSTOMER.EMAIL
FROM GENRE
JOIN TRACK ON TRACK.GENRE_ID = GENRE.GENRE_ID
JOIN INVOICE_LINE ON INVOICE_LINE.TRACK_ID = TRACK.TRACK_ID
JOIN INVOICE ON INVOICE.INVOICE_ID = INVOICE_LINE.INVOICE_ID
JOIN CUSTOMER ON CUSTOMER.CUSTOMER_ID = INVOICE.CUSTOMER_ID
GROUP BY CUSTOMER.FIRST_NAME,
         CUSTOMER.LAST_NAME,
         CUSTOMER.EMAIL,
         GENRE.NAME
HAVING GENRE.NAME = 'ROCK'
ORDER BY CUSTOMER.EMAIL;



-- 7. Let's invite the artists who have written the most rock music in our dataset. Write a 
-- query that returns the Artist name and total track count of the top 10 rock bands 

SELECT TOP 10 ARTIST.ARTIST_ID,
           ARTIST.NAME,
           COUNT(GENRE.GENRE_ID) AS NUMBER_OF_SONGS
FROM ARTIST
JOIN ALBUM ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
JOIN TRACK ON TRACK.ALBUM_ID = ALBUM.ALBUM_ID
JOIN GENRE ON GENRE.GENRE_ID = TRACK.GENRE_ID
GROUP BY ARTIST.ARTIST_ID,
         ARTIST.NAME,
         GENRE.NAME
HAVING GENRE.NAME = 'ROCK'
ORDER BY NUMBER_OF_SONGS DESC;



-- 8. Return all the track names that have a song length longer than the average song length. 
-- Return the Name and Milliseconds for each track. Order by the song length with the 
-- longest songs listed first 

SELECT NAME,
       MILLISECONDS
FROM TRACK
WHERE MILLISECONDS >
    (SELECT AVG(MILLISECONDS)
     FROM TRACK)
ORDER BY MILLISECONDS DESC;




-- 9. Find how much amount spent by each customer on artists? Write a query to return 
-- customer name, artist name and total spent 


SELECT CUSTOMER.CUSTOMER_ID,
       CUSTOMER.FIRST_NAME + ' ' + CUSTOMER.LAST_NAME AS FULL_NAME,
       ARTIST.NAME AS ARTIST_NAME,
       ROUND(SUM(TRACK.UNIT_PRICE),2) AS TOTAL_SPENT
FROM CUSTOMER
JOIN INVOICE ON INVOICE.CUSTOMER_ID = CUSTOMER.CUSTOMER_ID
JOIN INVOICE_LINE ON INVOICE_LINE.INVOICE_ID = INVOICE.INVOICE_ID
JOIN TRACK ON TRACK.TRACK_ID = INVOICE_LINE.TRACK_ID
JOIN ALBUM ON ALBUM.ALBUM_ID = TRACK.ALBUM_ID
JOIN ARTIST ON ARTIST.ARTIST_ID = ALBUM.ARTIST_ID
GROUP BY ARTIST.NAME,
         CUSTOMER.CUSTOMER_ID,
         CUSTOMER.FIRST_NAME,
         CUSTOMER.LAST_NAME
ORDER BY TOTAL_SPENT DESC;



-- 10. We want to find out the most popular music Genre for each country. We determine the 
-- most popular genre as the genre with the highest amount of purchases. Write a query 
-- that returns each country along with the top Genre. For countries where the maximum 
-- number of purchases is shared return all Genres 


WITH GENREPURCHASES AS (
    SELECT 
	    I.BILLING_COUNTRY AS COUNTRY,
        G.NAME AS GENRE,
        SUM(II.QUANTITY) AS PURCHASE_COUNT
FROM GENRE AS G
JOIN TRACK AS T ON T.GENRE_ID = G.GENRE_ID
JOIN INVOICE_LINE AS II ON II.TRACK_ID = T.TRACK_ID
JOIN INVOICE AS I ON I.INVOICE_ID = II.INVOICE_ID
GROUP BY G.NAME,
         I.BILLING_COUNTRY
),
COUNTRYMAXGENRE AS (
    SELECT COUNTRY,
	       MAX(PURCHASE_COUNT) AS MAX_PURCHASES
	FROM GENREPURCHASES
	GROUP BY COUNTRY
)

SELECT
    GP.COUNTRY AS COUNTRY,
	GP.GENRE AS TOP_GENRE,
	GP.PURCHASE_COUNT AS TOTAL_PURCHASE
FROM 
    GENREPURCHASES AS GP
JOIN
    COUNTRYMAXGENRE AS CM ON GP.COUNTRY = CM.COUNTRY
	                     AND GP.PURCHASE_COUNT = CM.MAX_PURCHASES
ORDER BY
    COUNTRY, TOP_GENRE;
	     


-- 11. Write a query that determines the customer that has spent the most on music for each 
-- country. Write a query that returns the country along with the top customer and how 
-- much they spent. For countries where the top amount spent is shared, provide all 
-- customers who spent this amount 


WITH CUSTOMER_TOTAL AS (
   SELECT C.CUSTOMER_ID,
          C.FIRST_NAME + ' ' + C.LAST_NAME AS FULL_NAME,
          C.COUNTRY,
          ROUND(SUM(I.TOTAL), 2) AS TOTAL_SPENT
   FROM CUSTOMER AS C
   JOIN INVOICE AS I ON I.CUSTOMER_ID = C.CUSTOMER_ID
   GROUP BY C.CUSTOMER_ID,
            C.FIRST_NAME,
            C.LAST_NAME,
            C.COUNTRY),
     COUNTRY_MAX_SPENT AS
  (SELECT COUNTRY,
          MAX(TOTAL_SPENT) AS MAX_SPENT
   FROM CUSTOMER_TOTAL
   GROUP BY COUNTRY)
SELECT C.CUSTOMER_ID AS TOP_CUSTOMER_ID,
       C.FULL_NAME,
       C.COUNTRY,
       C.TOTAL_SPENT AS AMOUNT_SPENT
FROM 
   CUSTOMER_TOTAL AS C
JOIN 
   COUNTRY_MAX_SPENT AS CM ON C.COUNTRY = CM.COUNTRY
AND 
   C.TOTAL_SPENT = CM.MAX_SPENT
ORDER BY 
   COUNTRY;



-- 12. Which support representative has generated the highest sales? 
--     Show employee name and total sales.


SELECT TOP 1
   E.FIRST_NAME + ' ' + E.LAST_NAME AS EMP_NAME,
   C.SUPPORT_REP_ID,
   ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2) AS TOTAL_SALES
FROM 
   EMPLOYEE AS E
JOIN CUSTOMER AS C ON E.EMPLOYEE_ID = C.SUPPORT_REP_ID
JOIN INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE AS II ON I.INVOICE_ID = II.INVOICE_ID
GROUP BY 
   E.FIRST_NAME,
   E.LAST_NAME,
   C.SUPPORT_REP_ID
ORDER BY 
   TOTAL_SALES DESC;



-- 13. What are the most purchased tracks for each customer? 
--     List customer name, track name, and quantity.


WITH CUSTOMER_TRACK_PURCHASES AS (
    SELECT
        C.FIRST_NAME + ' ' + C.LAST_NAME AS CUSTOMER_NAME,
    	T.NAME AS TRACK_NAME,
    	SUM(II.QUANTITY) AS TOTAL_QUANTITY,
    	RANK() OVER (PARTITION BY C.CUSTOMER_ID ORDER BY SUM(II.QUANTITY) DESC) AS TRACK_RANK
    FROM 
        CUSTOMER AS C
    JOIN INVOICE AS I ON I.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN INVOICE_LINE AS II ON II.INVOICE_ID = I.INVOICE_ID
    JOIN TRACK AS T ON T.TRACK_ID = II.TRACK_ID
    GROUP BY
        C.CUSTOMER_ID,
        C.FIRST_NAME,
    	C.LAST_NAME,
    	T.NAME
)
SELECT 
    CUSTOMER_NAME, 
	TRACK_NAME,
	TOTAL_QUANTITY
FROM
    CUSTOMER_TRACK_PURCHASES
WHERE
    TRACK_RANK = 1
ORDER BY
    CUSTOMER_NAME, TRACK_NAME;



-- 14. Which playlists have the highest number of track additions? 
--     Display playlist name and total track count.


SELECT 
    PT.PLAYLIST_ID,
    P.NAME AS PLAYLIST_NAME ,
    COUNT(P.PLAYLIST_ID) AS TOTAL_TRACK_COUNT
FROM PLAYLIST AS P
JOIN PLAYLIST_TRACK AS PT 
ON P.PLAYLIST_ID = PT.PLAYLIST_ID
GROUP BY
    P.NAME,
	PT.PLAYLIST_ID
ORDER BY
    PLAYLIST_NAME;



-- 15. Which artists have the highest total sales? Show artist name and total revenue.


SELECT 
    A.NAME AS ARTIST_NAME,
	ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2) AS TOTAL_REVENUE
FROM ARTIST AS A
JOIN ALBUM2 AS AL ON AL.ARTIST_ID = A.ARTIST_ID
JOIN TRACK AS T ON T.ALBUM_ID = AL.ALBUM_ID
JOIN INVOICE_LINE AS II ON T.TRACK_ID = II.TRACK_ID
GROUP BY
    A.NAME
ORDER BY
     TOTAL_REVENUE DESC;



-- 16. What is the total revenue generated for each genre by each support representative? 
--     Show rep name, genre, and total revenue.


SELECT
   E.FIRST_NAME + ' ' + E.LAST_NAME AS EMP_NAME,
   G.NAME AS GENRE_NAME,
   ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2) AS TOTAL_REVENUE
FROM 
   EMPLOYEE AS E
JOIN CUSTOMER AS C ON E.EMPLOYEE_ID = C.SUPPORT_REP_ID
JOIN INVOICE AS I ON C.CUSTOMER_ID = I.CUSTOMER_ID
JOIN INVOICE_LINE AS II ON I.INVOICE_ID = II.INVOICE_ID
JOIN TRACK AS T ON II.TRACK_ID = T.TRACK_ID
JOIN GENRE AS G ON T.GENRE_ID = G.GENRE_ID
GROUP BY 
   E.FIRST_NAME,
   E.LAST_NAME,
   G.NAME
ORDER BY 
   TOTAL_REVENUE DESC;



-- 17. What are the top 20 selling albums? Include album name, total sales, and number of 
--     tracks sold.

SELECT TOP 20
    AL.TITLE AS ALBUM_NAME,
	COUNT(AL.ALBUM_ID) AS NO_OF_TRACK_SOLD,
	ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2) AS TOTAL_SALES
FROM ALBUM AS AL
JOIN TRACK AS T ON T.ALBUM_ID = AL.ALBUM_ID
JOIN INVOICE_LINE AS II ON T.TRACK_ID = II.TRACK_ID
GROUP BY
    AL.TITLE,
	AL.ALBUM_ID
ORDER BY
    TOTAL_SALES DESC;



-- 18. How much revenue does each media type generate? Show media type name and total revenue.

SELECT
    M.NAME AS MEDIA_TYPE_NAME,
	ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2) AS TOTAL_REVENUE
FROM MEDIA_TYPE AS M
JOIN TRACK AS T ON T.MEDIA_TYPE_ID = M.MEDIA_TYPE_ID 
JOIN INVOICE_LINE AS II ON T.TRACK_ID = II.TRACK_ID
GROUP BY
    M.NAME
ORDER BY
    TOTAL_REVENUE DESC;



-- 19. Which tracks have the longest playtime? Include track name, playtime, and genre.

SELECT TOP 1
    T.NAME AS TRACK_NAME,
	G.NAME AS GENRE_NAME,
	T.MILLISECONDS AS PLAYTIME
FROM TRACK AS T
JOIN GENRE AS G ON T.GENRE_ID = G.GENRE_ID
GROUP BY
    T.NAME,
	T.MILLISECONDS,
	G.NAME
ORDER BY
    PLAYTIME DESC;



-- 20. What is the total lifetime value for each customer? Show customer name and cumulative 
--     amount spent.

WITH EACH_SPENT AS (
    SELECT 
        C.FIRST_NAME + ' ' + C.LAST_NAME AS CUSTOMER_NAME,
    	ROUND(SUM(II.UNIT_PRICE * II.QUANTITY),2)  AS EACH_AMOUNT_SPENT
    FROM CUSTOMER AS C
    JOIN INVOICE AS I ON I.CUSTOMER_ID = C.CUSTOMER_ID
    JOIN INVOICE_LINE AS II ON II.INVOICE_ID = I.INVOICE_ID
    JOIN TRACK AS T ON T.TRACK_ID = II.TRACK_ID
    GROUP BY
        C.FIRST_NAME,
    	C.LAST_NAME
)
SELECT
    CUSTOMER_NAME,
	SUM(EACH_AMOUNT_SPENT) OVER (ORDER BY (CUSTOMER_NAME)) AS CUM_AMOUNT_SPENT
FROM EACH_SPENT;
