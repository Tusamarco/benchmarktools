# MySQL Plan of action
## MySQL versions TBD:
MySQL versions
- 5.7
- 8.0.X
- 8.X.0
- 9.X.X
  
MariaDB
- 11.X.X (last LST availabel)
## Software we will use

Sysbench ([https://github.com/Tusamarco/sysbench/tree/percona-testing](https://github.com/Tusamarco/sysbench/tree/percona-testing))

sysbench tpcc ([https://github.com/Tusamarco/sysbench-tpcc](https://github.com/Tusamarco/sysbench-tpcc))
dbt-3 
Additional software, configs and tools from ([https://github.com/Tusamarco/benchmarktools](https://github.com/Tusamarco/benchmarktools))

PMM to monitor the tests

Minimal diversion from default settings in the mysql config.

## SQL to produce

Tests:

- Ingest (with sysbench ingest.lua) - 1 table; 10 tables
- sysbench (see details below for tests and commands)
- Sysbench - Tpcc

## Sysbench

Dimension:

50 tables
20 Million rows

Table definition with decently complex structure as:

- int
- smallint
- tinyint
- char
- date
- varchar
- timestamp
- Simple PK
- Compound index (with and without PK)
- Simple index on char
- Simple index on int
- Simple index on tinyint with low cardinality

Expected row dimension:

row 4 + 36 + 2 + 4 + 3 + ~51 + ~51 + 2 + 4 + 3 = 120 ~ 160 Bytes

```sql
CREATE TABLE `%s%d` (
  `id` %s,
  `uuid` char(36) NOT NULL,
  `millid` smallint(6) NOT NULL,
  `kwatts_s` int(11) NOT NULL,
  `date` date NOT NULL ,
  `location` varchar(50) NOT NULL,
  `continent` varchar(50) NOT NULL,
  `active` smallint UNSIGNED NOT NULL DEFAULT '1',
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `strrecordtype` char(3) COLLATE utf8_bin NOT NULL %s
  ) %s ROW_FORMAT=DYNAMIC  %s]],
```

We will have 2 main data set for sysbench:

**1 Set**

20 tables\
10 Million rows
- 160 = ~1.6 GB per table
- 120 = ~1.2   GB per table

**2 Set**

5 tables\
30 Million rows
- 160 = ~4.8 GB per table
- 120 = ~3.6   GB per table

**Running threads**

Test need to execute from 1 to X number of threads where X is lower than saturation point.
So first exercise is to identify the saturation point and use the previous run as limit.
IE if we execute runs 1 2 4 8 16 32 64 124 256 512 1024 2048 threads and we see that at 512 we hit saturation point, then the tests should not reach 512 threads.

### Tests high level description

 All using Uniform distribution unless specified see also [https://www.percona.com/blog/sysbench-and-the-random-distribution-effect/](https://www.percona.com/blog/sysbench-and-the-random-distribution-effect/)

### About the tests

We will have 3 moments for the tests:

1) Only Reads. This is also a Pre operation that will give us the READ statistics after data load and as such fully ordered

2) Write operations, which may cause (and will) page split/merge and data “fragmentation”

3) Read as Post write to identify the impact of the step 2

**Pre:**

**oltp_point_select**.lua - Point Select Pre -  Run single select query fetching ONE row by PK (Pre update)\
**oltp_read_only**.lua - read-only.rangeX - Param range.size=100 then range.size=1000 - perfroms range select with no write contention, before update (to compare with same test after update)\
**oltp_inlist_select**.lua - Random points select with IN Pre - uses the IN condition to retrieve a batch of 100 rows random ID (Pre update)\
**oltp_scan**.lua - Scan Pre - Cause a full table scan given a condition that is not null. (Pre Update)	\
**oltp_inlist_select**.lua -- Hot Point Pre - Params --random-points=100 --hot-points - Each select statement fetches 100 rows found by exact match on the PK. This is similar to random-points except this fetches the same 100 rows for all queries. The working set for this test is always cached.\

**Writes:**

**oltp_inlist_update**.lua - update-inlist - each update statement updates 100 rows selected by exact match on the PK via an in-list\		
**oltp_update_non_index**.lua for update-one test - Param index_updates=1  - One row update, each update statement updates one row. The same row in the database gets all updates\
**oltp_update_index**.lua -  should this use multiple rows - Param index_updates=100   - uses **oltp_update_index**.lua to run an update-only workload and secondary index maintenance is required.\
**oltp_update_non_index**.lua -- Param non_index_updates=100 -- run an update-only workload and secondary index maintenance is not required\
**oltp_update_non_index**.lua -- Param rand-type=special - with special updates are focus on a small set of IDs\
**oltp_delete**.lua - Delete/insert a set of rows\
**oltp_write_only**.lua - All write operation only with no read overload.\
**oltp_read_write**.lua - read-write.rangeX - Param range.size=100 then range.size=1000 - performs range selects while inserting (~2% - 1% write operations)\
**oltp_read_write with 25% writes** - read/write operations with 25% of write VS Reads\
**oltp_read_write with 50% writes** - read/write operations with 50% of write VS Reads\
**oltp_read_write with 75% writes** - read/write operations with 75% of write VS Reads

**Post:**

Re run all the tests in the Pre section.

## TPC like

**Dimension:**

- Warehouse 100
- Tables 10

**Range:**

load depending by the scenario but from 1 to 1024 threads is a common approach, point is never go above saturation.

**Reporting:**

see [https://www.percona.com/blog/tpcc-mysql-simple-usage-steps-and-how-to-build-graphs-with-gnuplot/](https://www.percona.com/blog/tpcc-mysql-simple-usage-steps-and-how-to-build-graphs-with-gnuplot/)

## Script run detail section

### Ingest

Script: ingest.lua

Runs:

1 table from 1 to N threads for X period of time no indexes PK is always on and autoincrement

commands:

```diff
- cleanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=0 --create_compound=0  --all_in_one=1 --threads=1

- run - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=1 --rate=100 --time=${time}  --threads=${threads}
```

10 table from 1 to N threads for X period of time no indexes PK is always on and autoincrement

commands:

```diff
cleanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=0 --create_compound=0  --all_in_one=0 --threads=1

- run - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --all_in_one=0 --rate=100 --time=${time}  --threads=${threads}
```

1 table from 1 to N threads for X period of time WITH indexes PK is always on and autoincrement

commands:

```diff
leanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=1 --create_compound=1 --all_in_one=1 --threads=10

- run - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=1 --rate=100 --time=${time}  --threads=${threads}
```

10 table from 1 to N threads for X period of time WITH indexes PK is always on and autoincrement

commands:

```bash
cleanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=1 --create_compound=1  --all_in_one=0 --threads=10

- run - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=0 --rate=100 --time=${time}  --threads=${threads}
```

### Sysbench Data Load (Prepare)

```bash
Script: oltp_write.lua
Runs: 
    - First set has 20 tables with 10Ml rows each table
    command:
		- cleanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --threads=10 --tables=20 --table_size=10000000    

 
    - Second set has 5 tables with 30Ml rows each table
    command:
		- cleanup/prepare - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=5 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --threads=10 --tables=5 --table_size=30000000
```

### Sysbench Read only tests

```bash
Point Select Pre -  Run single select query fetching ONE row by PK (Pre update)
-------------------------------------------------------------------------------
Script: oltp_point_select.lua
Runs: 
       Command:
       - run - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_point_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform run
```

```bash
Range Select - Perform range selects without write contention
-------------------------------------------------------------------------------
Script: oltp_range_select.lua
Runs:
	- the test should run executing only ONE type of range at each run, and then all together. There are 4 type of range selects: simple, sum, order, distinct

    Commands:
    - run simple - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform  --type_of_range=simple  run  	

    - run sum - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform  --type_of_range=sum  run  	

    - run order - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform  --type_of_range=order  run  	

    - run distinct - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform  --type_of_range=distinct  run  	

    - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform  --type_of_range=all  run
```

```bash
IN List selects - Performs Selects against a randomly selected list of IDs
-------------------------------------------------------------------------------
Script: oltp_inlist_select.lua
Runs:
	
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inselect_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --random_points=100 --hot_points=false  run
```

```bash
IN List selects Hot Spot - Performs Selects against a selected list of IDs that are always the same
------------------------------------------------------------------------------------------------------- 
Script: oltp_inlist_select.lua
Runs:
	
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inselect_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --random_points=100 --hot_points=true  run
```

```bash
Select Scan - Cause a full table scan given a condition that is not null
------------------------------------------------------------------------------------------------------- 
Script: oltp_inlist_select.lua
Runs:
	
	Command:
	For this test the number of threads cannot be bigger than the number of table, given the test run a scan 1 thread : 1 table. It may make sense to run it against one table firs then against all except the one already scan. This tests will see a lot of data moved from disk to memory and a good indicator of how the BP in InnoDB is dealing with page load/flush contention. 
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_scan.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --events=2  --threads=${threads} --rand-type=uniform  run
```

### Sysbench Write only tests

```bash
Update inlist - each update statement updates 100 rows selected by exact match on the PK via an in-list		
------------------------------------------------------------------------------------------------------- 
Script: oltp_inlist_update.lua 
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inselect_update.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --random_points=100 --hot_points=false  run
```

```bash
Update inlist Hot spot - each update statement updates 100 rows that are always the same PK via an in-list		
------------------------------------------------------------------------------------------------------- 
Script: oltp_inlist_update.lua 
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inselect_update.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --random_points=100 --hot_points=true  run
```

```bash
Update-one test - One row update, each update statement updates one row. 
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_non_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --non_index_updates=1  run
```

```bash
Update-Multi test - run an update-only workload and secondary index maintenance is not required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_non_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --non_index_updates=100  run
```

```bash
Update-Multi test Hot spot - run a multiple update-only workload on almost the same set or rows and secondary index maintenance is not required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_non_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=special --non_index_updates=10 run
```

```bash
Update-single  - run an update-only workload on 1 row a time on secondary index maintenance is required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --index_updates=1 run
```

```bash
Update-Multi  - run an update-only workload on 100 row a time on secondary index maintenance is required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --index_updates=100 run
```

```bash
Update-Multi Hot spot - run an multiple update-only on almost the same set or rows on secondary index maintenance is required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=special --index_updates=10 run
```

```bash
Update-Multi Hot spot - run an multiple update-only on almost the same set or rows on secondary index maintenance is required
------------------------------------------------------------------------------------------------------- 
Script: oltp_update_index.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=special --index_updates=10 run
```

```bash
Delete - Insert - Delete/insert a row per thread
------------------------------------------------------------------------------------------------------- 
Script: oltp_delete_insert.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_delete_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --delete_inserts=1 run
```

```bash
Delete - Insert - Delete/insert multiple rows per thread
------------------------------------------------------------------------------------------------------- 
Script: oltp_delete_insert.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_delete_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --delete_inserts=100 run
```

```bash
Replace - Replace a row per thread (instead Delete/Replace)
------------------------------------------------------------------------------------------------------- 
Script: oltp_delete_insert.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --use_replace --delete_inserts=1 run
```

```bash
Replace - Replace Multiple rows per thread (instead Delete/Replace)
------------------------------------------------------------------------------------------------------- 
Script: oltp_delete_insert.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --use_replace --delete_inserts=100 run
```

```bash
Write Only - All write operations together no reads in Uniform mode no transactions
------------------------------------------------------------------------------------------------------- 
Script: oltp_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --delete_inserts=1  run
```

```bash
Write Only Hot Spot - All write operations together no reads in Special mode no transactions
------------------------------------------------------------------------------------------------------- 
Script: oltp_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=special --delete_inserts=1  run
```

```bash
Write Only - All write operations together no reads in Uniform mode With transactions
------------------------------------------------------------------------------------------------------- 
Script: oltp_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=off --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --delete_inserts=1  run
```

```bash
Write Only Hot Spot - All write operations together no reads in Special mode With transactions
------------------------------------------------------------------------------------------------------- 
Script: oltp_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=off --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=special --delete_inserts=1  run
```

```bash
Reads and writes with ranges selects 100 with Uniform distribution
------------------------------------------------------------------------------------------------------- 
Script: oltp_read_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --point_selects=1 --range_size=100   run
```

```bash
Reads and writes with ranges selects 1000 with Uniform distribution
------------------------------------------------------------------------------------------------------- 
Script: oltp_read_write.lua
Runs:
	Command:
	 - run all - sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=${tables} --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --rate=100 --time=${time}  --threads=${threads} --rand-type=uniform --point_selects=1 --range_size=1000   run
```

### Handling script(s):

- to add WIP

### TPC-C command section
