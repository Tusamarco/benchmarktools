#!/bin/bash
#SET ENVIRONMENT VARIABLES:

TEST_NAME=${1:-"test-dbt3-ps834"}
MYSQL_HOST=${2:-"127.0.0.1"}
MYSQL_PORT=${3:-"3307"}
SCHEMA_NAME=${4:-"dbt3"}

MYSQL_DBT3_PATH=/opt/dbt3
DBT3_CNF=${MYSQL_DBT3_PATH}/dbt3.cnf

MYSQL_PATH=/opt/mysql_instances/${TEST_NAME}
RESULTS_PATH=${MYSQL_DBT3_PATH}/results/${TEST_NAME}
#/${test}_${subtest}_${engine}_$(date +'%Y-%m-%d_%H_%M').txt
if [ ! -d "$RESULTS_PATH" ]; then
    mkdir -p $RESULTS_PATH
fi
 

STATS=${RESULT_PATH}/dbt3_results.csv
#query=make-dbt3-db_${engine}-s5.sql

#Restart MYSQL to have a fresh environment
cd ${MYSQL_PATH}
echo "Stop MySQL if running in ${MYSQL_PATH}"
`pwd`/./stop

#clean file cache
sudo /sbin/sysctl vm.drop_caches=3

sleep 2
echo "Starting MySQL if running in ${MYSQL_PATH} and wait for MySQL to come up"
`pwd`/./start

sleep 10
nc -w 1 -z $MYSQL_HOST $MYSQL_PORT
while [ $? -ne 0 ] ; do
    echo "[Warning] Mysql did not start yet ($MYSQL_HOST : $MYSQL_PORT) waiting 10 secs"
    sleep 10
    nc -w 1 -z $MYSQL_HOST $MYSQL_PORT
done
mysql_start=$(date +%s)


for run in run-1 run-2; do
    for i in {1..22}; do 
        query=${i}.sql
        start=$(date +%s)
        mysql --defaults-file=${DBT3_CNF} -h${MYSQL_HOST} -P${MYSQL_PORT} -D ${SCHEMA_NAME} < ${MYSQL_DBT3_PATH}/query/mysql/${query} > /home/pythian/dbt3_results/${query}.result
        stop=$(date +%s)
        echo "${TEST_NAME},${start}, ${query}, ${run}, $(( ${stop} - ${start} ))"  >> ${STATS}
    done;
done; 

