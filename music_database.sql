--Q1.who is the senior most employee based on job title?

select * from employee
order by levels desc
limit 1;

--Q2.which countries have the most invoices?

select count(billing_country) as c ,billing_country  from invoice
group by billing_country
order by c desc;

--Q3.who are the top 3 values of total invoices?

select total  , billing_country
from invoice
order by total desc limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select sum(total) as invoice_totals, billing_city from invoice 
group by billing_city
order by invoice_totals desc ;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total  
from customer
join invoice on customer.customer_id = invoice.customer_id 
group by customer.customer_id
order by total desc 
limit 1;


----------------------------------------------/* Question Set 2 - Moderate */---------------------------------------------------------

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct customer.email, customer.first_name, customer.last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice_line.invoice_id = invoice.invoice_id
where track_id in (
	select track.track_id from track
    join genre on genre.genre_id = track.genre_id
    where genre.name like 'Rock')
order by email;

/*Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands */

select artist.artist_id, artist.Name, count(artist.artist_id) as total_track 
from track
join album on album.album_id  = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id =  track.genre_id 
where genre.name like 'Rock'
group by artist.artist_id 
order by total_track desc 
limit 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select name , milliseconds 
from track
where milliseconds > (select avg(milliseconds) from track )
order by milliseconds desc ;


--------------------------------------------------/* Question Set 3 - Advance */-----------------------------------------------------

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */
--Ans:
with my_cte as 
	( select artist.name, artist.artist_id, sum(invoice_line.unit_price * invoice_line.quantity) as totalSpent 
	from invoice_line
	join track on invoice_line.track_id = track.track_id
	join album on track.album_id = album.album_id
	join artist on album.artist_id = artist.artist_id
	group by 1,2
	order by 3 desc
	limit 1
	)

select customer.first_name, customer.last_name, my_cte.name, 
sum(invoice_line.unit_price * invoice_line.quantity) as total_spent
from customer 
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join album on track.album_id = album.album_id
join my_cte on album.artist_id = my_cte.artist_id
group by 1,2,3
order by 4 desc ;


/* Q2: We want to find out the most popular music Genre and respective country who has that music . We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */
	 
--Ans:

with my_cte as (
	select  c.country, g.name, g.genre_id, count (il.quantity) as purchases,
	row_number() over(partition by c.country order by count(il.quantity) desc  )as rowNo
	from invoice_line as il
	join invoice as i on il.invoice_id = i.invoice_id
	join customer as c on i.customer_id = c.customer_id 
	join track as t on il.track_id = t.track_id
	join genre as g on t.genre_id = g.genre_id
	group by 1,2,3
	order by 1 asc, 4 desc
)
select * from my_cte where my_cte.rowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

--Ans:

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1




-----------------------------------------------thank you----------------------------------------------------------------------------- 