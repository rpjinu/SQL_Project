use nft_data;
select * from pricedata;
select *,extract(year from event_date)
as sale_year
from pricedata;

#1.how many sale during

select count(token_id) from pricedata;

# 2.Return the top 5 most expensive transactions (by USD price) for this data set. Return the name, ETH price, and USD price, as well as the date.
select
    name,
    event_date,
    eth_price,
    usd_price
from pricedata
order by usd_price desc
limit 5;


#3.Return a table with a row for each transaction with an event column, a USD price column, and a moving average of USD price that averages the last 50 transactions.
select
     name,transaction_hash,event_date,usd_price,
    avg(usd_price) 
        OVER (
            ORDER BY event_date
            ROWS BETWEEN 50 PRECEDING AND CURRENT ROW
            ) AS "Moving_Avg"
FROM pricedata;

#4.Return all the NFT names and their average sale price in USD. Sort descending. Name the average column as average_price.

select name,avg(usd_price) over(order by usd_price desc) as average_price from pricedata;

#5.Return each day of the week and the number of sales that occurred on that day of the week, as well as the average price in ETH. Order by the count of transactions in ascending order.

select DAYNAME(event_date) as days_week,COUNT(transaction_hash) as number_of_sale,round(avg(usd_price)) as avg_ETH_price 
from pricedata
GROUP BY days_week
ORDER BY number_of_sale asc;

#6:-Construct a column that describes each sale and is called summary. The sentence should include who sold the NFT name, 
#who bought the NFT, who sold the NFT, the date, and what price it was sold for in USD rounded to the nearest thousandth.
# Here’s an example summary:
# “CryptoPunk #1139 was sold for $194000 to 0x91338ccfb8c0adb7756034a82008531d7713009d from 0x1593110441ab4c5f2c133f21b0743b2b43e297cb on 2022-01-14”

select concat(name,'  ','was sold for','  ','$',round(usd_price),'  ',
'to',' ',buyer_address,'  ','from ','  ',seller_address,' ','on',' ',event_date) as summary from pricedata;

#7:-Create a view called “1919_purchases” and contains any sales where “0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685” was the buyer.

CREATE VIEW 1919_purchases AS
SELECT * FROM pricedata
where buyer_address=0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685;

#call view 1919_purchases

select * from 1919_purchases;

#8:-Create a histogram of ETH price ranges. Round to the nearest hundred value. 

select round(eth_price/100) as ETH_price,count(ETH_price) as count,
rpad('',count(*),'*') as bar from pricedata
group by ETH_price
order by ETH_price;


#(9:-Return a unioned query that contains the highest price each NFT was bought for and a new column called status saying “highest” 
#with a query that has the lowest price each NFT was bought for and the status column saying “lowest”. 
#The table should have a name column, a price column called price, and a status column.
 #Order the result set by the name of the NFT, and the status, in ascending order.)
 
select name,MAX(eth_price) as highest_price,"highest" as status
from pricedata
group by name
 union 
 select name,MIN(eth_price) as lowest_price,"lowest" as status 
 from pricedata
 group by name
 order by name;
 
 #10:-What NFT sold the most each month / year combination? Also, what was the name and the price in USD? Order in chronological format.

SELECT   t1.month_year,t2.name,t1.max_price 
FROM (   
	SELECT  DATE_FORMAT(event_date, '%Y-%m') AS month_year, MAX(usd_price) AS max_price   
	FROM pricedata   
	GROUP BY month_year ) t1 
JOIN pricedata t2    
ON t1.month_year = DATE_FORMAT(t2.event_date, '%Y-%m')   AND t1.max_price = t2.usd_price
ORDER BY t1.month_year;

##11  Return the total volume (sum of all sales), round to the nearest hundred on a monthly basis (month/year).

select DATE_FORMAT(event_date, '%y-%m') AS month_year,round(sum(usd_price)) as sum_all_sales from pricedata
group by month_year
order by month_year;

#12  Count how many transactions the wallet "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685"had over this time period.

select count(seller_address) as transaction from pricedata
where seller_address = "0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685";

#13 
 #a) First create a query that will be used as a subquery. Select the event date, the USD price, and 
 #the average USD price for each day using a window function. Save it as a temporary table.
 #b) Use the table you created in Part A to filter out rows where the USD prices is below 10% of the daily average and return a new estimated value 
 #which is just the daily average of the filtered data

# A-- Create a temporary table using a common table expression (CTE)

CREATE TEMPORARY TABLE temp_daily_avg AS (
    SELECT
        event_date,
        usd_price,
        AVG(usd_price) OVER (PARTITION BY event_date) AS daily_avg_price
    FROM pricedata
);

#B-- Use the temporary table to filter outliers and calculate the new estimated value
CREATE TEMPORARY TABLE temp_filter_data AS (
    SELECT
        event_date,
        usd_price
    FROM temp_daily_avg                         #here we use previous table  we created in A
    WHERE usd_price >= 0.1 * daily_avg_price
);

-- Calculate the new estimated value as the average of the filtered data from table in A
SELECT
    event_date,
    round(AVG(usd_price),3) AS estimated_value
FROM temp_filter_data  
GROUP BY event_date;


#14 Give a complete list ordered by wallet profitability (whether people have made or lost money)
select 
      ifnull(b.buyer_address,s.seller_address) as wallet,
      ifnull(s.total_recieved,0)-ifnull(b.total_spent,0) as profit
from(
     select buyer_address,sum(usd_price) as total_spent
     from pricedata
     group by buyer_address
) b
left join(
        select seller_address,sum(usd_price) as total_recieved
        from pricedata
        group by seller_address
) s
on b.buyer_address=s.seller_address

union

select 
      ifnull(b.buyer_address,s.seller_address) as wallet,
      ifnull(s.total_recieved,0)-ifnull(b.total_spent,0) as profit
from(
     select buyer_address,sum(usd_price) as total_spent
     from pricedata
     group by buyer_address
) b
right join(
        select seller_address,sum(usd_price) as total_recieved
        from pricedata
        group by seller_address
) s
on b.buyer_address=s.seller_address
where b.buyer_address is null;