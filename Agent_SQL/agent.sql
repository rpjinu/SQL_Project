create database agent;

use agent;
#1.create first table
CREATE TABLE agent_commission (
    agent_code INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    working_area VARCHAR(50),
    commission DECIMAL(10, 2),
    mobile_no BIGINT
);

#2 create second table
CREATE TABLE customer_details (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    customer_city VARCHAR(50),
    agent_code INT,
    order_date DATE,
    FOREIGN KEY (agent_code) REFERENCES agent_commission(agent_code)
);

#3.Insert records in both tables.
-- Insert into agent_commission table
INSERT INTO agent_commission (agent_code, first_name, last_name, working_area, commission, mobile_no)
VALUES (1, 'John', 'Doe', 'Delhi', 20000, 9876543210),
       (2, 'Jane', 'Smith', 'Mumbai', 18000, 9123456789),
       (3, 'Robert', 'Williams', 'Chandigarh', 15000, 9988776655),
       (4,'rakesh','das','delhi',28000,7865143589);
       
-- Insert into customer_details table
INSERT INTO customer_details (customer_id, customer_name, customer_city, agent_code, order_date)
VALUES (1, 'Alice', 'Delhi', 1, '2022-08-15'),
       (2, 'Bob', 'Mumbai', 2, '2021-12-11'),
       (3,'tony','bengaluru',4,'2024-09-23');
       
       
#4.Display Agents from Delhi
SELECT * FROM agent_commission WHERE working_area = 'Delhi';

#5.Display output where the commission of the agent is greater than 15000.
SELECT * FROM agent_commission WHERE commission >15000;

#6.Give the output columns where the city is Mumbai.
SELECT * FROM agent_commission WHERE working_area='mumbai';

#7.Display the output by a specified agent code 4.
SELECT * FROM agent_commission WHERE agent_code=4;

#8. Order Agents by First Name
SELECT * FROM agent_commission ORDER BY first_name;

#9.Display the limited number of rows in output using LIMIT.
SELECT * FROM agent_commission 
limit 3;

#10.Count and show the number of cities in the agent commission table.
SELECT COUNT(DISTINCT working_area) AS number_of_cities FROM agent_commission;

#11.Agent with Minimum Commission
SELECT * FROM agent_commission ORDER BY commission ASC LIMIT 1;

#12.Total Commission
SELECT SUM(commission) AS total_commission FROM agent_commission;

#13.Average Commission
SELECT avg(commission) AS total_commission FROM agent_commission;

#14.Group by City and Count Agents
SELECT working_area, COUNT(agent_code) AS agent_count 
FROM agent_commission 
GROUP BY working_area;

#15.Convert Mobile Number to Integer Using CAST
SELECT CAST(mobile_no AS UNSIGNED) FROM agent_commission;

#16.Orders After a Specific Date
SELECT * FROM customer_details WHERE order_date > '2010-01-01';

#17.Concat the First name and Last name of the agent commission table.
select concat(first_name,' ',last_name) as full_name from agent_commission;


#19.Replace the city Chandigarh with Haryana in the agent commission table.
SET SQL_SAFE_UPDATES = 0;
UPDATE agent_commission SET working_area = 'Haryana' WHERE working_area = 'Chandigarh';
#check the update result
select * from agent_commission;
    #enale the update in sql
SET SQL_SAFE_UPDATES = 1;


#20.Create the sample table Orders with columns OrderID, OrderNumber, and PersonID.
create table orders(
OrderID int primary key,
OrderNumber int,
PersonID int
);


#21.Assign Primary and Foreign Key
-- Already done in table definitions
ALTER TABLE orders 
ADD CONSTRAINT fk_person FOREIGN KEY (personID) REFERENCES agent_commission(agent_code);


#22. Perform Left Join
SELECT * 
FROM agent_commission a
LEFT JOIN customer_details c
ON a.agent_code = c.agent_code;

#23.Perform Right join and Inner join operations on Agent commission and Customer details table.
-- Right Join
SELECT * 
FROM agent_commission a
RIGHT JOIN customer_details c
ON a.agent_code = c.agent_code;

-- Inner Join
SELECT * 
FROM agent_commission a
INNER JOIN customer_details c
ON a.agent_code = c.agent_code;

#24.Perform Union clause on  Agent commission and Customer details table.
SELECT agent_code, first_name, last_name, working_area FROM agent_commission
UNION
SELECT agent_code, customer_name, customer_city, NULL FROM customer_details;

#25.Use the CASE function to show the details of agents with a commission greater than 12000 and agent code 1 from the agent commission table.
SELECT agent_code, first_name, 
CASE 
  WHEN commission > 12000 AND agent_code = 1 THEN 'High Commission Agent'
  ELSE 'Other Agent'
END AS agent_status
FROM agent_commission;













