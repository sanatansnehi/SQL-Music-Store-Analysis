                                           /*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

SELECT employee_id,first_name,last_name
FROM Employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC
LIMIT 1;

/* Q3: What are top 3 values of total invoice? */

SELECT total
FROM Invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) as Inovice_total
FROM Invoice
GROUP BY billing_city,total
ORDER BY total DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT C.customer_id, C.first_name,C.last_name,SUM(total) AS Total_Spending
FROM Customers AS C
INNER JOIN Invoice AS I
ON C.customer_id = I.customer_id
GROUP BY  C.first_name,C.last_name,I.total,C.customer_id
ORDER BY total DESC
LIMIT 1;


                                      /* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT email,first_name,last_name
FROM Customers AS C
INNER JOIN Invoice AS I
ON C.customer_id = I.customer_id
JOIN Invoice_Line AS IL ON I.invoice_id = IL.invoice_id
JOIN Track AS T ON T.track_id = IL.track_id
JOIN Genre AS G ON G.genre_id = T.genre_id
WHERE G.name = 'Rock'
ORDER BY email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT Artist.artist_id,Artist.name,COUNT(Artist.artist_id) AS no_of_songs
FROM Track
JOIN Albums ON Albums.album_id = Track.album_id
JOIN Artist ON Artist.artist_id = Albums.artist_id
JOIN Genre ON Genre.genre_id = Track.genre_id
WHERE Genre.name = 'Rock'
GROUP BY Artist.artist_id,Artist.name
ORDER BY no_of_songs
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,millisecond
FROM Track
WHERE millisecond > (
	SELECT AVG(millisecond) AS avg_track_length
	FROM Track
)
ORDER BY millisecond DESC;

                                         /* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS(
	SELECT Artist.artist_id AS artist_id,
	Artist.name AS artist_name,
	SUM(Invoice_Line.unit_price * Invoice_Line.quantity) AS total_spent
	FROM Invoice_Line
	JOIN Track ON Track.track_id = Invoice_Line.track_id
	JOIN Albums ON Albums.album_id = Track.album_id
	join Artist ON Artist.artist_id = Albums.artist_id
	GROUP BY Artist.artist_id,Artist.name
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT C.customer_id,C.first_name,C.last_name,bsa.artist_name,SUM(Il.unit_price * Il.quantity) AS amount_spent
FROM Invoice AS I
JOIN Customers AS C ON C.customer_id = I.customer_id
JOIN Invoice_Line AS IL ON IL.invoice_id = I.invoice_id
JOIN Track AS T ON T.track_id = Il.track_id
JOIN Albums AS A ON A.album_id = T.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = A.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH most_popular_genre AS(
	SELECT COUNT(Invoice_Line.quantity) AS purchase,Customers.country,Genre.name,Genre.genre_id,
	ROW_NUMBER() OVER(PARTITION BY Customers.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
	FROM Invoice_Line
	JOIN Invoice ON Invoice.invoice_id = Invoice_Line.invoice_id
	JOIN Customers ON Customers.customer_id = Invoice.customer_id
	JOIN Track ON Track.track_id = Invoice_Line.track_id
	JOIN Genre ON Genre.genre_id = Track.genre_id
	GROUP BY Customers.country,Genre.name,Genre.genre_id
	ORDER BY Customers.country ASC,purchase DESC
)
SELECT * FROM most_popular_genre 
WHERE RowNo <= 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH highest_spent_customer AS(
	SELECT Customers.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spent_by_customer,
	ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
	FROM Invoice
	JOIN Customers ON Customers.customer_id = Invoice.customer_id
	GROUP BY 1,2,3,4
	ORDER BY 4 ASC, 5 DESC
)
SELECT * FROM highest_spent_customer
WHERE RowNo <= 1;