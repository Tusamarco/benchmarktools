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
    
Whatever you choose, the image in the directory:
```bash
 ll /opt/mysql_instances_EBS/
total 24
-rwxr-xr-x. 1 mysql mysql 6487 Oct 22  2021 mysql8_instance.sh
drwxr-x---  6 mysql mysql 4096 Nov 23 16:31 test-dbt3-ps834
drwxr-x---  6 mysql mysql 4096 Nov 23 16:52 test-ps834
drwxr-x---  7 mysql mysql 4096 Nov 23 17:13 test-sysbench-my834
drwxr-x---  6 mysql mysql 4096 Nov 23 16:27 test-tpcc-ps834
```
Contains already few mysql instances ready to go. 

    