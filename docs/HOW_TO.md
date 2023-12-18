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
