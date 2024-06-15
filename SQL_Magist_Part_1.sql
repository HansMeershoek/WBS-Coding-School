use magist;



select distinct product_category_name_english
from product_category_name_translation;

-- how many unique products_categories
select count(distinct product_category_name_english) as nr_prod_category
from product_category_name_translation;
# answer unique products 74 

-- -- What categories of products does Magist have?
select distinct product_category_name_english as nr_prod_category,
p.product_category_name
from products p
left join product_category_name_translation pt
on p.product_category_name = pt.product_category_name;


select 
	distinct(product_category_name_english) as Tech_category_name
from products p
left join product_category_name_translation pt on p.product_category_name = pt.product_category_name
where product_category_name_english 
		in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony');


#How many products of these tech categories have been sold (within the time window of the database snapshot)?

select count(distinct order_id) as total_products_sold
from order_items;
# answer: total '98666'  products sold 

#Tech products sold

select count(distinct order_id) as tech_products_sold
from order_items oi
join products p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english 
		in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony');


select 
    (select count(distinct order_id) from order_items) as total_products_sold,
    (select count(distinct order_id)
     from order_items oi
     join products p on oi.product_id = p.product_id
     join product_category_name_translation pct on p.product_category_name = pct.product_category_name
     where product_category_name_english in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
    ) as tech_products_sold;

#Percentage of tech products sold

select round((tech_products_sold / total_products_sold) * 100,2) as tech_products_percentage
from 
    (select count(distinct order_id) as tech_products_sold
        from order_items oi
        join products p on oi.product_id = p.product_id
        join product_category_name_translation pct on p.product_category_name = pct.product_category_name
        where product_category_name_english 
            in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
    ) as tech,
    (select count(*) as total_products_sold
        from order_items) as total;


#What’s the average price of the products being sold?

select round(avg(price),2) as average_price
from order_items oi
join products p on oi.product_id = p.product_id;


select round(avg(price),2) as average_price_techproduct
from order_items oi
join products p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image',
'computers_accessories','small_appliances','watches_gifts','telephony');
-- answer average_price_techproduct '136.91'


#Are expensive tech products popular?

select
    case
        when oi.price > 1000 then 'Expensive'
        else 'Affordable'
    end as price_category,
    count(*) as product_count
from order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english 
            in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
group by price_category;
7.



#How many months of data are included in the magist database?


select min(order_purchase_timestamp) as earliest_date, 
		max(order_purchase_timestamp) as latest_date
from orders;


#How many months of data are included in the Magist database?
select 
timestampdiff(month, min(order_purchase_timestamp), 
max(order_purchase_timestamp)) as months_of_data
from orders;


#How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?


select count(distinct seller_id) as total_sellers
from sellers;
# answer: 3095 total_sellers


select count(distinct s.seller_id) as tech_sellers
from sellers s
join order_items oi on s.seller_id = oi.seller_id
join products p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english 
in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image',
'computers_accessories','small_appliances','watches_gifts','telephony');


#Number of tech sellers per product category.

select product_category_name_english, count(distinct seller_id) as nr_tech_selllers_by_category
from order_items
inner join products 
on products.product_id=order_items.product_id
inner join product_category_name_translation 
on product_category_name_translation.product_category_name=products.product_category_name 
where product_category_name_english in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
group by product_category_name_english
order by nr_tech_selllers_by_category desc;


#Percentage of tech sellers

select  round((tech_sellers / total_sellers) * 100,2) as tech_sellers_percentage
from (select count(distinct s.seller_id) as tech_sellers
    from sellers s
    join order_items oi on s.seller_id = oi.seller_id
    join products p on oi.product_id = p.product_id
	join product_category_name_translation pct on p.product_category_name = pct.product_category_name
    where product_category_name_english 
            in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
) as tech,
(select count(*) as total_sellers
    from sellers) as total;


#What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?

select round(sum( price),0) as total_earnings
from order_items;


#Total amount earned per month by all sellers
select 
    year(order_purchase_timestamp) as order_year,
    month(order_purchase_timestamp) as order_month,
    round(sum(oi.price), 2) as monthly_income
from order_items oi
join orders o on oi.order_id = o.order_id
group by order_year, order_month
order by order_year;

#Total amount earned per month by tech sellers.

select 
    year(o.order_purchase_timestamp) as order_year,
    month(o.order_purchase_timestamp) as order_month,
    round(sum(oi.price), 2) as monthly_income
from order_items oi
left join orders o on oi.order_id = o.order_id
left join products p on oi.product_id = p.product_id
left join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where pct.product_category_name_english in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony')
group by order_year, order_month
order by order_year;


#Total amount earned by Tech sellers.

select round(sum( oi.price),0) as tech_earnings
from order_items oi
join products p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english 
in ('audio','consoles_games','electronics','pc_gamer','computers','
tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony');
# answer: 32231714  tech_earnings

SELECT 
    product_category_name_english,
    ROUND(SUM(price), 0) AS Total_Price,
    ROUND(SUM(price) / (SELECT SUM(price) FROM order_items) * 100, 2) AS Percentage 
FROM order_items
INNER JOIN products ON products.product_id = order_items.product_id
INNER JOIN product_category_name_translation ON product_category_name_translation.product_category_name = products.product_category_name 
WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'pc_gamer', 'computers', 'tablets_printing_image', 'computers_accessories', 'small_appliances', 'watches_gifts', 'telephony')
GROUP BY product_category_name_english
order  by Percentage desc;


#Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?

select round(sum(oi.price) / timestampdiff(month, min(o.order_purchase_timestamp), max(o.order_purchase_timestamp)),0) as avg_monthly_income
from order_items oi
left join orders o on oi.order_id = o.order_id;



#Average monthly income of Tech sellers.

select round(sum(oi.price) / timestampdiff(month, min(o.order_purchase_timestamp), max(o.order_purchase_timestamp)),0) as avg_monthly_tech_income
from order_items oi
join orders o on oi.order_id = o.order_id
join products p on oi.product_id = p.product_id
join product_category_name_translation pct on p.product_category_name = pct.product_category_name
where product_category_name_english 
            in ('audio','consoles_games','electronics','pc_gamer','computers','tablets_printing_image','computers_accessories','small_appliances','watches_gifts','telephony');


