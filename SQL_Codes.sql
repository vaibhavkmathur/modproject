#Query for MoM Brand Revenue
select Month(Product.CreatedDate), Product.Brand, SUM(orderd.Price) AS Revenue
from
(select  * 
from order_details 
) as orderd
inner join
(select * 
from product_master 
) as Product
on orderd.ItemID = Product.ContentID
group by Month(Product.CreatedDate), Product.Brand
order by SUM(orderd.Price) desc;



#Query for MoM Category Revenue
select Month(product_master.Createddate), product_master.CategoryCode, SUM(order_details.Price) AS Revenue
from
(select * 
from order_details 
) as order_details
inner join
(select * 
from product_master 
) as product_master
on order_details.ItemID = product_master.ContentID
group by Month(product_master.Createddate), product_master.CategoryCode;



#Query for MoM Brand wise Customer count
select Month(Order_Customer.OrderDate), product_master.Brand, COUNT(distinct Order_Customer.Customerid) AS Num_Customers
from
(select order_details.*, c.Customerid from 
(select *
from order_details 
) as order_details
left join
(select * 
from order_master) as c 
on order_details.OrderID = c.Contentid) as Order_Customer
inner join
(select * 
from product_master 
) as product_master
on Order_Customer.ItemID = product_master.ContentID
group by Month(Order_Customer.OrderDate), product_master.Brand order by Num_Customers desc;


#Query for MoM Category wise Customer count
select Month(Order_Customer.orderdate), product_master.CategoryCode, COUNT(distinct Order_Customer.Customerid) AS Num_Customers
from
(select  order_details.*, order_master.Customerid from 
(select *
from order_details 
) as order_details
left join
(select * 
from order_master
) as order_master 
on order_details.OrderID = order_master.Contentid) as Order_Customer
inner join
(select * 
from product_master 
) as product_master
on Order_Customer.ItemID = product_master.ContentID
group by Month(Order_Customer.orderdate), product_master.CategoryCode order by Num_Customers desc;



#1 Average monthly revenue per customer
select month(OrderDate) as month, sum(TotalPrice)/count(distinct customerid) as avg_monthly_revenue from order_master
group by month(OrderDate);


#3 Unique SKUs per customer per month
select month, sum(d.sku_count)/count(distinct d.customerID) as avg_unique_sku_id
from
(
select c.customerID, month(c.OrderDate) as month, count(distinct c.ITEMid) as sku_count
from
(
select a.customerID, b.orderID, b.ITEMid, a.OrderDate
from  order_master  a
join order_details  b
on b.orderID = a.contentID
)  c
group by c.customerID, month(c.OrderDate)
) as d
group by month;


#4 Active retailers per month
# value of numeratoR
select MONTH(a.orderdate) AS MONTH,count(distinct a.customerID) as cnt_active_customer 
from order_master  a
join customer_master as b
on a.customerid = b.customerid 
group by MONTH(a.orderdate);

#value of denominator
select MONTH(CustomerCreateddate),count(distinct customerID) as total_customer 
from customer_master
group by MONTH(CustomerCreateddate);



#5 purchased in August and September but not in October
select count(distinct f.customerid)
from 
(
select distinct(c.customerid)
from
(select a.* 
from
(select distinct customerid
from order_master WHERE MONTH(orderdate) = 8
) as a
inner join
(select distinct customerid
from order_master where MONTH(orderdate) = 9
) as b
on a.customerid = b.customerid) as c
inner join
(select distinct customerid 
from order_master where MONTH(orderdate) != 10
)  as d
on c.customerid =d.customerid ) as f;



# 6 average buying cycle of a retailer - monthly 
select month(OrderDate), (count(distinct contentid)/count(distinct customerid)) as avg_order 
from order_master
group by month(OrderDate);



#7 best and worst active retailers
SELECT Customerid, Count(*) as Orders, SUM(TotalPrice) as Price
from order_master
GROUP BY Customerid ORDER BY Price DESC limit 10;
 
SELECT Customerid, Count(*) as Orders, SUM(TotalPrice) as Price
FROM order_master
GROUP BY Customerid ORDER BY Price ASC limit 10;

SELECT Customerid, Count(*) as Orders, SUM(TotalPrice) as Price
FROM order_master
GROUP BY Customerid ORDER BY Orders ASC limit 10 ;

SELECT Customerid, Count(*) as Orders, SUM(TotalPrice) as Price
FROM order_master
GROUP BY Customerid ORDER BY Orders DESC limit 10; 	

#Agent Analysis
# Avg revenue per agent per month
select d.month, d.agentid, sum(d.revenue)/count(distinct d.Customerid) as avg_Rev_per_month, sum(revenue) as total_revenue
from
(
select a.AgentID, a.Customerid, year(b.OrderDate) as month, sum(b.TotalPrice) as revenue
from customer_master_final as a
join ordermaster as b
on a.Customerid = b.Customerid
group by a.AgentID, a.Customerid, year(b.OrderDate)
) as d
where d.month = 8 and d.agentid>0
group by d.month, d.agentid
order by sum(revenue) DESC 
Limit 10;

# Avg agent revenue month on month 
select d.month, sum(d.revenue)/count(distinct d.Customerid) as avg_per_month
from 
(
select a.AgentID, a.Customerid, year(b.OrderDate) as month, sum(b.TotalPrice) as revenue
from customer_master_final as a
join ordermaster as b
on a.Customerid = b.Customerid
group by a.AgentID, a.Customerid, year(b.OrderDate)
) as d
where d.month = 8 or d.month = 9 or d.month = 2010
group by d.month;

#unique skus of top 10 agent per month
select e.month, e.AgentID, count(distinct e.ItemID) as unique_skus
from
(
select c.*, d.ItemID
from
(
select a.AgentID, a.Customerid, b.Contentid , year(b.OrderDate) as month
from customer_master_final as a
join ordermaster as b
on a.Customerid = b.Customerid
group by a.AgentID, a.Customerid,b.Contentid, year(b.OrderDate)
) as c
join 
(select OrderID, ItemID
from orderdetails ) as d
on c.Contentid = d.OrderID
) as e
where e.month = 2010
group by e.month,e.AgentID
order by count(distinct e.ItemID) DESC
Limit 10;

# Agent with last active date more than 3 days past
select UserID as agentid_inactive_3_days
from agentmaster 
where datediff(CURDate(), LastActivitydate) >3;

# Inactive agents for 10 days+
select UserID as agentid_inactive_10_days
from agentmaster 
where  datediff(CURDate(), LastActivitydate) >10;









