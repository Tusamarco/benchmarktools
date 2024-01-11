# How to: prepare the Benchmark environment

## Overview
Before you even start I suggest you to read [this page with concepts](concepts.md) and example of [action plan](plan.md)


The benchmarking environment is compose by 2 main components:
- The database image
- The testing code

To run the tests you must first create an EC2 instance for the DB using the [image](https://eu-central-1.console.aws.amazon.com/ec2/home?region=eu-central-1#ImageDetails:imageId=ami-06fa99993a0a168e6) 
After that you can choose IF use an EBS volume or use the default auto allocate.

If you decide to use the local volume remember that you need to prepare it like:

```sh
 fdisk /dev/nvme2n1p1 
 mkfs.ext4 /dev/nvme2n1p1
 mount -o noatime,nodiratime -t ext4 /dev/nvme2np1 /opt/mysql_instances
```

You can also build your own DB server, but in this case be sure to:
- Create the directory `/opt/results`
- Once that instance had a populated DB make a copy,because you __MUST__ reset the data every time you run a new test set, to be consistent 



### Database
If you use the preconfigured image, you will find there a set of MySQL/PS software and also a set of preconfigured/loaded data sets.
The software is in:
```bash
ll /opt/mysql_templates/
total 6754560
drwxr-xr-x  12 mysql mysql       4096 Nov 23 13:36 mysql-8.0.34-linux-glibc2.17-x86_64
-rw-r--r--   1 mysql mysql  531952231 Jun 22 10:27 mysql-8.0.34-linux-glibc2.17-x86_64.tar.gz
drwxr-xr-x   9 mysql mysql       4096 Oct 30 17:41 mysql-8.0.35-linux-glibc2.17-x86_64
-rw-r--r--   1 mysql mysql  439284500 Oct 15 17:52 mysql-8.0.35-linux-glibc2.17-x86_64.tar.xz
drwxr-xr-x   9 mysql mysql       4096 Oct 30 17:42 mysql-8.2.0-linux-glibc2.17-x86_64
-rw-r--r--   1 mysql mysql  452383016 Oct 13 05:26 mysql-8.2.0-linux-glibc2.17-x86_64.tar.xz
lrwxrwxrwx   1 mysql mysql         56 Nov 23 13:17 mysql-8P -> /opt/mysql_templates/mysql-8.0.34-linux-glibc2.17-x86_64
drwxrwxr-x  13 mysql mysql       4096 Mar  7  2023 Percona-Server-8.0.31-23-Linux.x86_64.glibc2.17
-rw-r--r--   1 mysql mysql 1398754166 Jan 31  2023 Percona-Server-8.0.31-23-Linux.x86_64.glibc2.17.tar.gz
drwxrwxr-x  13 mysql mysql       4096 Jun  7 15:10 Percona-Server-8.0.33-25-Linux.x86_64.glibc2.17
-rw-r--r--   1 mysql mysql 1432659062 Oct 30 17:30 Percona-Server-8.0.33-25-Linux.x86_64.glibc2.17.tar.gz
drwxrwxr-x  16 mysql mysql       4096 Nov  9 16:21 Percona-Server-8.0.34-26-Linux.x86_64.glibc2.17
-rw-r--r--   1 mysql mysql 1441294623 Oct 30 17:27 Percona-Server-8.0.34-26-Linux.x86_64.glibc2.17.tar.gz
drwxrwxr-x  14 mysql mysql       4096 Sep  7  2022 Percona-XtraDB-Cluster_8.0.28-19.1_Linux.x86_64.glibc2.17
-rw-r--r--   1 mysql mysql 1159985754 Jul 13  2022 Percona-XtraDB-Cluster_8.0.28-19.1_Linux.x86_64.glibc2.17.tar.gz
lrwxrwxrwx   1 mysql mysql         47 Nov  9 14:50 PS-8P -> Percona-Server-8.0.34-26-Linux.x86_64.glibc2.17
lrwxrwxrwx   1 mysql mysql         57 Sep  7  2022 PXC8 -> Percona-XtraDB-Cluster_8.0.28-19.1_Linux.x86_64.glibc2.17
-rwxr-xr-x.  1 mysql mysql        262 Oct 22  2021 start
-rwxr-xr-x.  1 mysql mysql        374 Oct 22  2021 stop
```
The preloaded data is in:
```bash
 ll /opt/mysql_instances_EBS/
total 24
-rwxr-xr-x. 1 mysql mysql 6487 Oct 22  2021 mysql8_instance.sh
drwxr-x---  6 mysql mysql 4096 Nov 23 16:31 test-dbt3-ps834
drwxr-x---  6 mysql mysql 4096 Nov 23 16:52 test-ps834
drwxr-x---  7 mysql mysql 4096 Nov 23 17:13 test-sysbench-my834
drwxr-x---  6 mysql mysql 4096 Nov 23 16:27 test-tpcc-ps834
```
That contains already few MySQL instances ready to go. 
To use them, COPY the content inside the `/opt/mysql_instance/` directory.
To do so will have 2 positive effects:
1. You will keep an original copy of the data, tha will allow you to perform multiple tests starting always from the same consistent point. 
2. The test will be executed running locally and not from an EBS.

Inside each directory you will find a `./start & ./stop` command, use them to start/stop the instance.  

### Testing code
We have three main tests:
- Ingest
- Sysbench 
- TPC-c 

the code in this repository exists to help you in running the tests in an easy way.
It has two type of scripts:
- To run the tests
- To parse the logs 

The main scrip that handle the tests is `run_bench_tests.sh` you can get details with `--help`.
The above script is managing the sysbench and TPC-c tests.
While to transform the  logs `read_and_get_from_file.sh` is the one, again `--help` to discover how to use it. 

DBt3 has a separate set of scripts inside the `dbt3` directory.

To run the Sysbench tests, you must use the version from my repository. It has some modifications that I have inserted to facilitate the benchmarking execution and output. Nothing there is changing the performance behaviour or impacting on the internals. 
Sysbench (https://github.com/Tusamarco/sysbench/tree/percona-testing)
sysbench tpcc (https://github.com/Tusamarco/sysbench-tpcc) 

dbt-3 Additional software, configs and tools from (https://github.com/Tusamarco/benchmarktools/software/dbt3) 

# How to: run tests 
## Sysbench 
Sysbench has many different tests, each one testing a particular aspect of the database. As such we cannot consider it a valid tool to mimic application load, however is very good to identify specific differences between MySQL versions. 
In this benchmarking suite I have implemented a quite large number of tests [see here](plan.md)

The wrapper to make our life easier and run the different tests in a comfortable way is the script `run_bench_tests.sh` under the `software` directory.
As usual the right way to start is to look in the `help`

```bash
 sh run_bench_tests.sh --help

Command line: Usage: run_bench_tests.sh --command=run --test <test Identifier> --testname <sysbench|tpcc|ingest> --subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list --dryrun]

script: run_bench_tests.sh 

Parameters:
        --command: The action to perform cleanup|prepare|run
        --debug: extended output to standard out
        --dryrun: Printout the commands that will run without executing them
        --engine: Engine to use default Innodb [innodb|myrocks]
        --error_ignore: Set the level for the option --mysql-ignore-errors. Default none
        --filter_subtest: Text to filter the subtest list. IE: "select" for sysbench will only return the select tests
        --help: this help                        
        --host: MySQL host
        --port: MySQL port
        --reconnect: sysbench will reconnect after the indicated number of events. Default 0 - no reconnect
        --schemaname: Schema name 
        --subtest_list: List of all sub test to see all (--subtest_list --command all --testname all)
        --subtest: The specific subtest you want to run OR all (see output of --subtest_list)
        --sysbench_test_dimension: we have 2 standard dimension small and large. Default is small:
								SYSNBENCH_ROWS_LARGE=30000000
								SYSNBENCH_ROWS_SMALL=10000000
								SYSNBENCH_TABLES_LARGE=5
								SYSNBENCH_TABLES_SMALL=20
			So small has smaller tables but more of them, large is more about few tables and more rows.
        --tablename: Table name for sysbench and Ingest 
        --test: The ID for the current test set IE PS8034
        --testname: The testname you want to run [ingest|sysbench|tpcc]
        --testrun: Run the tests with  thread and only for 10 seconds, just to check if they may work
        --THREADS: the set of threads to use to run the tests use double quote as "2 4 8 16"
        --TIME: the execution time for the tests in seconds IE 600


Sub Tests
	To visualize the subtests lists:
	run_bench_tests.sh --subtest_list --testname all --command all
	Will show all sub tests for all commands and type of tests
    
   	run_bench_tests.sh --subtest_list --testname ingest --command run
   	Will show only the subtests for Ingest and for the run command.
```
To get the list of all existing tests:
` sh run_bench_tests.sh --subtest_list --testname all --command all`

This command will return an extensive list of tests. From there you will be able to decide which ones to run and filter them.
For instance if you want to run all the select tests in the __RUN__ command:
```bash
run_bench_tests.sh --test Hello_World  --testname sysbench --command run  --filter_subtest select  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension small  --host my_ip --port 3306 --schemaname my_schema
```
The `--filter_subtest select` will filter for you only the selects. Or you can use the same prameter to run only updates: --filter_subtest update. And so on. 

A full example that will run all the select and write is:
```bash
 cat run_sysbench.sh 
#!/bin/bash
testidentifyer=${1:-"PS8035"}
 
bin_path="/opt/tools/benchmarktools/software"
    for dimension in small large; do
        echo "Running dimension: ${dimension}"
        for type in select write select; do
            echo "Running type: ${type}"
            for run in 1 ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname windmills_${dimension}"

                bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname windmills_${dimension}
            done;
        done;
    done;
```

While running the tests we will also generate a lot of data in form of logs.
By default the __logs__ are locate in the `/opt/results` directory, if you need to change it, just modify the `run_bench_test.sh` file when you see `RESULTS=/opt/results` with whatever fits you.
In the log directory you will see something like this:
```bash
 ll /opt/results/sysbench
total 19872
-rw-r--r-- 1 root root 2786075 Dec 12 16:01 MY8034_large_select_1_run_all_select_innodb_2023-12-12_10_49.txt
-rw-r--r-- 1 root root 2906304 Dec 13 08:29 MY8034_large_select_1_run_all_select_innodb_2023-12-13_03_15.txt
-rw-r--r-- 1 root root 4692585 Dec 13 03:15 MY8034_large_write_1_run_all_write_innodb_2023-12-12_16_01.txt
-rw-r--r-- 1 root root 2425458 Dec 11 18:31 MY8034_small_select_1_run_all_select_innodb_2023-12-11_13_34.txt
-rw-r--r-- 1 root root 2882755 Dec 12 10:49 MY8034_small_select_1_run_all_select_innodb_2023-12-12_05_48.txt
-rw-r--r-- 1 root root 4619160 Dec 12 05:48 MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31.txt
```
Please note the path /opt/results/__sysbench__, this is the __test type__ (--testname, I know is misleading) and we will have 3 of them: DBt3, Sysbench and TPCc. 

Each file will contain the test label (--test, I know is misleading) in this case MY8034_${dimension}_${type}_${run} then the subtest name and finally date and time it starts. 

Once you have all the Logs in place you can extract the information using the other script `read_and_get_from_file.sh`. 

A good start is to do something like this:
`export PARSEPATH="/opt/results/sysbench/"; for file in `ls ${PARSEPATH}`;do  ./read_and_get_from_file.sh $file $PARSEPATH /opt/results/processed --noask;done`

Using the option `--noask` will skip the request at each iteration to approve the action and will extract all files by itself.
You will see something like:
```bash
Running extract
File /opt/results/sysbench//MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31.txt OK
.. Calculating the number of line to process:
=============================================
FILE To Parse MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31.txt
Number of lines 81331
Local Path  /opt/results/sysbench/
Resulting filename HEAD MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31
Output dir/file /opt/results/processed/MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31/MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31
=============================================

OK ..
Progress : [#######################################-] 98%
---------------------------------------------
Process complete 2023-12-13_14_18_36
=============================================
```
For each log file in the output given directory you will see something like this:
```bash
ll /opt/results/processed/
total 19588
drwxr-xr-x 3 root root   20480 Dec 13 14:10 MY8034_large_select_1_run_all_select_innodb_2023-12-12_10_49
drwxr-xr-x 3 root root   16384 Dec 13 14:11 MY8034_large_select_1_run_all_select_innodb_2023-12-13_03_15
drwxr-xr-x 3 root root   36864 Dec 13 14:13 MY8034_large_write_1_run_all_write_innodb_2023-12-12_16_01
drwxr-xr-x 3 root root   20480 Dec 13 14:15 MY8034_small_select_1_run_all_select_innodb_2023-12-11_13_34
drwxr-xr-x 3 root root   20480 Dec 13 14:16 MY8034_small_select_1_run_all_select_innodb_2023-12-12_05_48
drwxr-xr-x 3 root root   32768 Dec 13 14:18 MY8034_small_write_1_run_all_write_innodb_2023-12-11_18_31
drwxr-xr-x 3 root root   16384 Dec 11 13:11 PS8035_large_select_1_run_all_select_innodb_2023-12-09_05_38
drwxr-xr-x 3 root root   20480 Dec 11 13:13 PS8035_large_select_1_run_all_select_innodb_2023-12-09_18_27
drwxr-xr-x 3 root root   28672 Dec 11 13:14 PS8035_large_write_1_run_all_write_innodb_2023-12-09_10_49
drwxr-xr-x 3 root root   20480 Dec 11 13:15 PS8035_small_select_1_run_all_select_innodb_2023-12-08_08_54
drwxr-xr-x 3 root root   16384 Dec 11 13:16 PS8035_small_select_1_run_all_select_innodb_2023-12-09_00_36
drwxr-xr-x 3 root root   36864 Dec 11 13:19 PS8035_small_write_1_run_all_write_innodb_2023-12-08_13_51
```
Inside each directory:
```bash
ll /opt/results/processed/MY8034_large_select_1_run_all_select_innodb_2023-12-12_10_49
total 340
drwxr-xr-x 2 root root  20480 Dec 13 14:10 data
-rw-r--r-- 1 root root 305404 Dec 13 14:10 MY8034_large_select_1_run_all_select_innodb_2023-12-12_10_49_histogram.txt
-rw-r--r-- 1 root root  15590 Dec 13 14:10 MY8034_large_select_1_run_all_select_innodb_2023-12-12_10_49_summary.csv
```
Where `data` contains the details of each iteration per threads number.

The `_histogram.txt` will contain the data about the latency as `4280.318|2` where `latency in ms|instances`

The `_summary.csv` contains the results of the tests and is what we will use to generate our images and statistics. 
ie:
```csv
subtest,TotalTime,RunningThreads,totalEvents,Events/s,Tot Operations,operations/s,tot reads,reads/s,Tot writes,writes/s,oterOps/s,latencyPct95,Tot errors,errors/s,Tot reconnects,reconnects/s,Latency(ms) min, Latency(ms) max, Latency(ms) avg, Latency(ms) sum
select_run_range_simple,200,1,91099.00,455.49,91099.00,455.49,91099.00,455.49,0.00,0.00,0.00,4.82,0.00,0.00,0.00,0.00,0.00,0.07,0.00,199.96
select_run_range_simple,200,2,100657.00,503.27,100657.00,503.27,100657.00,503.27,0.00,0.00,0.00,12.08,0.00,0.00,0.00,0.00,0.00,0.09,0.00,399.95
select_run_range_simple,200,4,148678.00,743.37,148678.00,743.37,148678.00,743.37,0.00,0.00,0.00,16.12,0.00,0.00,0.00,0.00,0.00,0.05,0.01,799.92
select_run_range_simple,200,8,206023.00,1030.07,206023.00,1030.07,206023.00,1030.07,0.00,0.00,0.00,22.28,0.00,0.00,0.00,0.00,0.00,0.10,0.01,1599.86
select_run_range_simple,200,16,270807.00,1353.95,270807.00,1353.95,270807.00,1353.95,0.00,0.00,0.00,25.74,0.00,0.00,0.00,0.00,0.00,0.25,0.01,3199.86
select_run_range_simple,200,32,338080.00,1690.17,338080.00,1690.17,338080.00,1690.17,0.00,0.00,0.00,41.10,0.00,0.00,0.00,0.00,0.00,0.58,0.02,6400.10
select_run_range_simple,200,64,373601.00,1867.59,373601.00,1867.59,373601.00,1867.59,0.00,0.00,0.00,71.83,0.00,0.00,0.00,0.00,0.00,1.73,0.03,12801.09
select_run_range_simple,200,128,415928.00,2078.74,415928.00,2078.74,415928.00,2078.74,0.00,0.00,0.00,114.72,0.00,0.00,0.00,0.00,0.00,5.28,0.06,25605.35
select_run_range_simple,200,256,427775.00,2137.25,427775.00,2137.25,427775.00,2137.25,0.00,0.00,0.00,397.39,0.00,0.00,0.00,0.00,0.00,1.20,0.12,51218.42
select_run_range_simple,200,512,430027.00,2146.81,430027.00,2146.81,430027.00,2146.81,0.00,0.00,0.00,926.33,0.00,0.00,0.00,0.00,0.00,3.28,0.24,102478.40
select_run_range_simple,201,1024,429330.00,2139.93,429330.00,2139.93,429330.00,2139.93,0.00,0.00,0.00,1708.63,0.00,0.00,0.00,0.00,0.00,5.14,0.48,205120.95
```
An example of how to orgaize the stats is in the file benchmarking_sysbench_example.xlsm in software, however you need to have MS Excel to use it. 

I will add a tool (working on it), that will generate all the graphs as done in the Excel file. 









