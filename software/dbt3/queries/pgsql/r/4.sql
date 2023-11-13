-- @(#)4.sql	2.1.8.1
-- TPC-H/TPC-R Order Priority Checking Query (Q4)
-- Functional Query Definition
-- Approved February 1998
:b
:x
:o
select o_orderpriority, count(*) as order_count
from orders
where o_orderdate >= date ':1'
    and o_orderdate < cast (date ':1' + interval '3 month' as date)
    and exists (
        select
            *
        from
            q4
        where
            l_orderkey = o_orderkey
    )

group by o_orderpriority
order by o_orderpriority;
:e
