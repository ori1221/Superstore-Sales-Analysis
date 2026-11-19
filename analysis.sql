-- Analysis 1: Overall Sales and Profitability
select sum("Sales") as SumOfSales,
sum("Profit") as Profit, 
round(
        (
            SUM("Profit") / NULLIF(SUM("Sales"), 0) * 100
        )::numeric,
        2
    ) as ProfitPercentage

from sample_superstore;






-- Analysis 2: Profitability by Product Category
select "Category",
sum("Sales") as SumOfSales,
sum("Profit") as Profit, 
round(
        (
            SUM("Profit") / NULLIF(SUM("Sales"), 0) * 100
        )::numeric,
        2
    ) as ProfitPercentage
from sample_superstore  
group by "Category"  order by ProfitPercentage desc;






-- Analysis 3: Profitability by Product Subcategory
select "Sub-Category" ,
sum("Sales") as SumOfSales,
sum("Profit") as Profit,
round(
        (
            sum("Profit") / nullif(sum("Sales"), 0) * 100
        )::numeric,
        2
    ) as ProfitPercentage

from sample_superstore
group by "Sub-Category" order by sum("Profit") asc;





-- Analysis 4: Discount Impact on Profitability
select 
case 
	when "Discount" = 0 then 'no discount'
	when "Discount" <= 0.2 then 'low discount'
	when "Discount" > 0.2 and "Discount" <= 0.4 then 'medium discount'
	when "Discount" > 0.4 then 'high discount'
end  as discount_group,
count(*) as sales_record_count,
sum("Sales") as SumOfSales,
sum("Profit") as Profit,
round(
        (
            sum("Profit") / nullif(sum("Sales"), 0) * 100
        )::numeric,
        2
    ) as ProfitPercentage
from sample_superstore 
group by discount_group order by Profit;




-- Analysis 5: Monthly Sales and Profit Trends
select
extract(year from to_date("Order Date", 'MM/DD/YYYY')) as year ,
extract(month from to_date("Order Date", 'MM/DD/YYYY')) as month,
sum("Sales") as SumOfSales, 
sum("Profit") as Profit,
count(distinct "Order ID") as ordercount 
from sample_superstore
group by year, month
order by year, month;



-- Analysis 6: Top 10 Customers by Sales
select "Customer ID" as ID,
"Customer Name" as nameofC,
count(distinct "Order ID") as ordercount,
sum("Sales") as total_spent,
sum("Profit") as profit
from sample_superstore 
group by id , nameofC order by total_spent desc
limit 10 ;



-- Analysis 7: Repeat Customers
select 
case 
	when order_count = 1 then 'one'
	when order_count >= 2 then 'more_than_one'
end as num_of_orders,
count(*) as num_of_customers,
round (((count(*) * 100.0 / sum(count(*)) over())) :: numeric,
	2) as customer_percentage
from 
(select "Customer ID" as ID,
count(distinct "Order ID") as order_count
from sample_superstore 
group by id ) as customer_orders

group by num_of_orders;







-- Analysis 8: Month-over-Month Profit Changes
with monthly_sales as (
select
extract(year from to_date("Order Date", 'MM/DD/YYYY')) as year ,
extract(month from to_date("Order Date", 'MM/DD/YYYY')) as month,
sum("Sales") as SumOfSales, 
sum("Profit") as Profit,
count(distinct "Order ID") as ordercount
from sample_superstore
group by year, month
order by year, month  ),

monthly_comparison as (
	select year,
		month,
		profit,
		lag(profit) over (order by year, month) as previous_profit
	from monthly_sales
		)

select year,
month,
profit,
previous_profit,
-- Percentage changes can be misleading when previous profit is negative.
round((((profit - previous_profit) * 100) / nullif(previous_profit,0)) :: numeric,
	2) as profit_change_pct
from monthly_comparison
order by year,month;












-- Analysis 9: Profitability by Category and Discount Group
with Category_discount as (
select "Category",
	case 
	when "Discount" = 0 then 'no discount'
	when "Discount" <= 0.2 then 'low discount'
	when "Discount" > 0.2 and "Discount" <= 0.4 then 'medium discount'
	when "Discount" > 0.4 then 'high discount'
end  as discount_group, 
	"Sales",
	"Profit"
from sample_superstore )

select "Category",
discount_group, 
count(*) as total_sales_records,
sum("Sales") as total_sales,
sum("Profit") as total_profit,
round( (sum("Profit") * 100.0 / nullif(sum("Sales"),0)) ::numeric,
	2) as profit_percentage
from Category_discount
group by "Category", discount_group 
order by "Category" ,
	case discount_group
		when 'no discount' then 1
        when 'low discount' then 2
        when 'medium discount' then 3
        when 'high discount' then 4
		
	end;
	



