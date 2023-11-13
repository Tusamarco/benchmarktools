-- Create dbt3Schema 

USE dbt3;
DROP table if exists customer;
CREATE TABLE customer (
	c_custkey INTEGER,
	c_name VARCHAR(25),
	c_address VARCHAR(40),
	c_nationkey INTEGER,
	c_phone CHAR(15),
	c_acctbal DECIMAL(10,2),
	c_mktsegment CHAR(10),
	c_comment VARCHAR(117)
);

DROP table if exists lineitem;
CREATE TABLE lineitem (
	l_orderkey INTEGER,
	l_partkey INTEGER,
	l_suppkey INTEGER,
	l_linenumber INTEGER,
	l_quantity DECIMAL(10,2),
	l_extendedprice DECIMAL(10,2),
	l_discount DECIMAL(10,2),
	l_tax DECIMAL(10,2),
	l_returnflag CHAR(1),
	l_linestatus CHAR(1),
	l_shipDATE DATE,
	l_commitDATE DATE,
	l_receiptDATE DATE,
	l_shipinstruct CHAR(25),
	l_shipmode CHAR(10),
	l_comment VARCHAR(44)
);

DROP table if exists nation;
CREATE TABLE nation (
	n_nationkey INTEGER,
	n_name CHAR(25),
	n_regionkey INTEGER,
	n_comment VARCHAR(152)
);

DROP table if exists orders;
CREATE TABLE orders (
	o_orderkey INTEGER,
	o_custkey INTEGER,
	o_orderstatus CHAR(1),
	o_totalprice DECIMAL(10,2),
	o_orderDATE DATE,
	o_orderpriority CHAR(15),
	o_clerk CHAR(15),
	o_shippriority INTEGER,
	o_comment VARCHAR(79)
);

DROP table if exists part;
CREATE TABLE part (
	p_partkey INTEGER,
	p_name VARCHAR(55),
	p_mfgr CHAR(25),
	p_brand CHAR(10),
	p_type VARCHAR(25),
	p_size INTEGER,
	p_container CHAR(10),
	p_retailprice DECIMAL(10,2),
	p_comment VARCHAR(23)
);

DROP table if exists partsupp;
CREATE TABLE partsupp (
	ps_partkey INTEGER,
	ps_suppkey INTEGER,
	ps_availqty INTEGER,
	ps_supplycost DECIMAL(10,2),
	ps_comment VARCHAR(199)
);

DROP table if exists region;
CREATE TABLE region (
	r_regionkey INTEGER,
	r_name CHAR(25),
	r_comment VARCHAR(152)
);

DROP table if exists supplier;
CREATE TABLE supplier (
	s_suppkey  INTEGER,
	s_name CHAR(25),
	s_address VARCHAR(40),
	s_nationkey INTEGER,
	s_phone CHAR(15),
	s_acctbal DECIMAL (10,2),
	s_comment VARCHAR(101)
);

DROP table if exists time_statistics;
CREATE TABLE time_statistics (
	task_name VARCHAR(40),
	s_time TIMESTAMP default current_timestamp,
	e_time TIMESTAMP,
	int_time INTEGER);


DROP table if exists dataset;
CREATE TABLE dataset (
	id INTEGER NOT NULL,
	count INTEGER NOT NULL,
	PRIMARY KEY (count));




ALTER TABLE supplier ADD PRIMARY KEY (s_suppkey);
CREATE INDEX i_s_nationkey ON supplier (s_nationkey); 
ALTER TABLE part ADD PRIMARY KEY (p_partkey); 
ALTER TABLE partsupp ADD PRIMARY KEY (ps_partkey, ps_suppkey); 
CREATE INDEX i_ps_partkey ON partsupp (ps_partkey); 
CREATE INDEX i_ps_suppkey ON partsupp (ps_suppkey); 
ALTER TABLE customer ADD PRIMARY KEY (c_custkey); 
CREATE INDEX i_c_nationkey ON customer (c_nationkey); 
ALTER TABLE orders ADD PRIMARY KEY (o_orderkey); 
CREATE INDEX i_o_orderdate ON orders (o_orderdate); 
CREATE INDEX i_o_custkey ON orders (o_custkey); 
ALTER TABLE lineitem ADD PRIMARY KEY (l_orderkey, l_linenumber); 
CREATE INDEX i_l_shipdate ON lineitem (l_shipdate); 
CREATE INDEX i_l_suppkey_partkey ON lineitem (l_partkey, l_suppkey); 
CREATE INDEX i_l_partkey ON lineitem (l_partkey); 
CREATE INDEX i_l_suppkey ON lineitem (l_suppkey); 
CREATE INDEX i_l_receiptdate ON lineitem (l_receiptdate); 
CREATE INDEX i_l_orderkey ON lineitem (l_orderkey); 
CREATE INDEX i_l_orderkey_quantity ON lineitem (l_orderkey, l_quantity); 
CREATE INDEX i_l_commitdate ON lineitem (l_commitdate); 
ALTER TABLE nation ADD PRIMARY KEY (n_nationkey); 
CREATE INDEX i_n_regionkey ON nation (n_regionkey); 
ALTER TABLE region ADD PRIMARY KEY (r_regionkey); 


analyze table supplier
analyze table part
analyze table partsupp
analyze table customer
analyze table orders
analyze table lineitem
analyze table nation
analyze table region
