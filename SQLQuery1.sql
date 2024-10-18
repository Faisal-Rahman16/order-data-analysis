--find top 10 highest reveue generating products
select Top 10 product_id, sum(sale_price) as Top_Revenue 

from dbo.df_orders
group by product_id
order by Top_Revenue desc

--find top 5 highest selling products in each region

With sale as (Select region, product_id, sum(sale_price) as sales,
RANK() over ( partition by region order by sum(sale_price) desc) as rank
from dbo.df_orders
group by region, product_id
)

select region, product_id, sales
 from sale 
 where rank <= 5 
 order by region,sales desc

 --find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023

With cte as (Select  YEAR(order_date) as order_year, MONTH(order_date) as order_month, sum(sale_price) as sales 
from df_orders
group by YEAR(order_date), MONTH(order_date)
) 

Select order_month, 
sum (case when order_year = 2022 then sales else 0 end ) as sales_2022 ,
sum(case when order_year = 2023 then sales else 0 end ) as sales_2023

from cte
group by order_month
order by order_month




--for each category which month had highest sales 

With cte as 

	(Select category, format(order_date,'yyyyMM') as order_year_month, SUM(sale_price) as sale,
	ROW_NUMBER() over( Partition By category order by SUM(sale_price) desc) as rn

	from df_orders

	group by category, format(order_date,'yyyyMM')
	) 
Select category, order_year_month, sale
from cte
 
 where rn= 1 


 --which sub category had highest growth by profit in 2023 compare to 2022

	with cte as (
	
		Select sub_category, YEAR(order_date) as order_year ,sum(profit) as profit
 
		 from df_orders
		 group by sub_category, YEAR(order_date)
		 ),

	 cte2 as (Select sub_category,
	sum(case when order_year = 2022 then profit else 0 end) as profit_2022,
	sum(case when order_year = 2023 then profit else 0 end) as profit_2023

	from cte
	group by sub_category),

	cte_ranked as(

		Select sub_category, (profit_2023-profit_2022) as profit_growth,
		RANK() over(order by profit_2023-profit_2022 desc) as rn
		from cte2)

	Select sub_category, profit_growth
	from cte_ranked
	where rn = 1 