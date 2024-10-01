use opt_db
-- 1. Non-optimized  query

explain select
    (select concat(sub1.item_name, ": ", sub1.cnt)
     from (select mi.item_name, count(*) as cnt
        from fd_order_items oi
     join fd_orders o on o.id = oi.order_id
     join fd_menu_items mi on oi.menu_item_id = mi.id
    where o.order_date > '2023-01-01'
     group by mi.item_name) as sub1
     where cnt = (select round(avg(cnt), 0)
                  from (select mi.item_name, count(*) as cnt
        from fd_order_items oi
        join fd_orders o on o.id = oi.order_id
    join fd_menu_items mi on oi.menu_item_id = mi.id
      where o.order_date > '2023-01-01'
        group by mi.item_name) as sub2)
     limit 1) as avg_cnt;


-- 2. Optimized with cte
create index idx_fd_orders_order_date on fd_orders(order_date);

explain with cte as (
select o.id as order_id, oi.menu_item_id, mi.item_name
 from fd_orders o
 join fd_order_items oi on o.id = oi.order_id
 join fd_menu_items mi on oi.menu_item_id = mi.id
 where o.order_date > '2023-01-01'
),

cnt_menu_items as (
    select item_name, count(*) as cnt
    from cte
    group by item_name
)

select
    (select concat(item_name, ": ", cnt)
     from cnt_menu_items
where cnt = (select round(avg(cnt), 0) from cnt_menu_items)
limit 1) as avg_cnt;




