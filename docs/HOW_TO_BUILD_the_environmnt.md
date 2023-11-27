# How to prepare the Benchmark environment

## Overview
Before you even start you suggest you to read [this page with concepts](concepts.md) and example of [action plan](plan.md)


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











     