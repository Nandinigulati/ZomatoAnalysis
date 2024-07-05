--GOLD MEMBERS

drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(
    gd_userid INT PRIMARY KEY,
    gold_signup_date date); 

INSERT INTO goldusers_signup(gd_userid,gold_signup_date)
 VALUES (101,'2017-09-22'),
(103,'2017-04-20'), 
(104,'2017-12-10');

-- REGULAR MEMBERS

drop table if exists users;
CREATE TABLE users(
    userid INT PRIMARY KEY,
    signup_date DATE); 

INSERT INTO users(userid,signup_date) 
 VALUES (111,'2017-11-10'),
(112,'2017-05-10'),
(113,'2017-01-20'),
(114,'2017-11-20'),
(115,'2017-10-22');

SELECT userid AS user_id
FROM goldusers_signup
UNION
SELECT userid AS user_id
FROM users;

--COMBINED USERS

DROP TABLE IF EXISTS combined_users;
CREATE TABLE combined_users AS
SELECT gd_userid AS com_userid
FROM goldusers_signup
UNION
SELECT userid AS com_userid
FROM users;

CREATE INDEX idx_combined_users_com_userid ON combined_users(com_userid);

select * from combined_users;
describe combined_users;

--SALES

drop table if exists sales;
CREATE TABLE sales(
userid INT,
created_date date,
product_id INT,
FOREIGN KEY(userid) REFERENCES combined_users(com_userid) ON DELETE SET NULL,
FOREIGN KEY(product_id) REFERENCES product(product_id) ON DELETE SET NULL
); 
describe sales;

INSERT INTO sales(userid,created_date,product_id) 
 VALUES (111,'2017-10-22',1),
(113,'2017-09-20',2),
(112,'2017-10-02',3),
(113,'2017-05-28',4),
(113,'2017-12-10',5),
(114,'2017-04-04',1),
(111,'2017-03-27',1),
(115,'2017-09-12',2),
(115,'2017-12-02',3),
(114,'2017-01-22',4),
(101,'2017-01-06',5),
(103,'2017-12-28',5),
(103,'2017-09-01',4),
(104,'2017-03-04',3),
(101,'2017-04-22',2),
(112,'2017-05-10',3);

--PRODUCTS

drop table if exists product;
CREATE TABLE product(product_id INT PRIMARY KEY AUTO_INCREMENT,
product_name VARCHAR(10),
price INT); 

INSERT INTO product(product_name,price) 
 VALUES
('pizza',980),
('dal',870),
('taco',330),
('wrap',499),
('momos',799);


select * from sales;
select * from product;
select * from goldusers_signup;
select * from users;


-- What is the total amount spent by each user

SELECT s.userid, SUM(p.price) AS total_amount_spent
FROM sales s
JOIN product p ON s.product_id = p.product_id
GROUP BY s.userid;

--How many days did a user purschase 

SELECT userid, COUNT(DISTINCT created_date) AS number_of_days
FROM sales 
GROUP BY userid;

--What is the first product by each of the user

SELECT s.userid, s.product_id AS first_product_id
FROM (
    SELECT userid, MIN(created_date) AS first_purchase_date
    FROM sales
    GROUP BY userid
) AS first_purchase
JOIN sales s ON first_purchase.userid = s.userid AND first_purchase.first_purchase_date = s.created_date;


--What is the most purchased item and how many times was it purchased

--(quantity)
SELECT COUNT(s.product_id) AS total_no, p.product_name
FROM sales s
JOIN product p ON s.product_id=p.product_id
GROUP BY product_name;


SELECT p.product_name, pc.total_no AS total_purchase
FROM (
    SELECT product_id, COUNT(*) AS total_no
    FROM sales
    GROUP BY product_id
    ORDER BY total_no DESC
    LIMIT 1
) AS pc
JOIN product p ON pc.product_id = p.product_id;

-- if points are given after every purchase which are equal to the product_id, then calculate the total points each user has

SELECT userid, SUM(product_id) AS total_points
FROM sales
GROUP BY userid;
