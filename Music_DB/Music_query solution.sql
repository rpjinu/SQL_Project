---check out all table 
select * from artist;
select * from album;
select * from genre;
select * from customer;
select * from employee;
select * from  invoice;
select * from  invoice_line;
select * from track;
select * from playlist;
select * from playlist_track;


---1.Who is the senior most employee on job title?
with temp1 as(
select title as job_title,concat(trim(first_name),' ',trim(last_name)) as full_name,
(extract(year from current_date)-extract(year from birthdate)) as age,
ROW_NUMBER() OVER (PARTITION BY title ORDER BY birthdate ASC) AS rank
from employee)
select job_title,full_name,age
from temp1
where rank=1;


---2.which countries most invoices?
SELECT billing_country, COUNT(*) AS total_invoice
FROM invoice
GROUP BY billing_country
order by total_invoice desc limit 1;

---3.what are the top 3 value of total_invice?
select * from invoice
order by total desc limit 3;


---4.which city has best customer?,we would like to throw professional music festival made most money
select billing_country,billing_city,sum(total) as revenue 
from invoice
group by billing_city,billing_country
order by revenue desc limit 1;


---5.who is the best customer? the customer spent most amount of money.
select concat(trim(first_name),' ',trim(last_name)) as customer_name,
round(sum(total)) as revenue 
from customer c
join invoice i on c.customer_id=i.customer_id
group by customer_name
order by revenue desc limit 1;


---6.write query return email,full name,gerne all rocks music listener return list in alphabetical order A
select distinct(c.email),concat(trim(c.first_name),' ',trim(c.last_name)) as customer_name 
from customer c
join invoice i on c.customer_id=i.customer_id
join invoice_line l on i.invoice_id=l.invoice_id
where track_id in (
 select track_id from track t
 join genre g on t.genre_id=g.genre_id
 where g.name='Rock'
)
order by c.email asc;


---7.let's invite the artist artist who has most number of rock music,write query artist name,total rock count top 10 band
select a.name,count(*) as number_of_songs from track t
join album l on t.album_id=l.album_id
join artist a on a.artist_id=l.artist_id
join genre g on t.genre_id=g.genre_id
where g.name='Rock'
group by a.name
order by number_of_songs desc limit 10;


---8.return all track name have song length longer then average song length.
---return the name and millisecond for each track.order by song length with the logest song listed first
select name,milliseconds from track 
where milliseconds >(select avg(milliseconds)as avg_track_len from track)
order by milliseconds desc;


---9.find how much amount spent by each customer on artists?
----write a query to return customer name,artist name and total spent.
WITH best_sell_artist AS (
    SELECT 
        a.artist_id AS artist_id, 
        a.name AS artist_name,
        SUM(il.unit_price * il.quantity) AS revenue
    FROM artist a
    JOIN album al ON a.artist_id = al.artist_id
    JOIN track t ON al.album_id = t.album_id
    JOIN invoice_line il ON t.track_id = il.track_id
    GROUP BY a.artist_id, a.name
)
SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
    bsa.artist_name, 
    SUM(il.unit_price * il.quantity) AS amount_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album al ON t.album_id = al.album_id
JOIN best_sell_artist bsa ON bsa.artist_id = al.artist_id
GROUP BY c.customer_id, customer_name, bsa.artist_name
ORDER BY amount_spent DESC;

