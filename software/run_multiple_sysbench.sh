#!/bin/bash
#./run_multiple_sysbench.sh sysbench test 127.0.0.1 innodb 
engine=${5:-"innodb"}
test=${1:-"sysbencha"}
testname=${2:-"test"}
host=${3:-"10.0.1.96"}
port=${4:-3306}
schemaname="windmills"
tablename="mills"
MAINDIR=/opt/results
#TIME=60
TIME=1200
TABLES=50
ROWS=1000000
WHAREHOUSES=20
SCALE=20
THREADS="32 64 92"
#THREADS="2 4 8 16 32 64 128 256 512"
USER="app_test"
PW="test"

LOGFILE=$MAINDIR/${testname}/sysbench_${test}_${engine}_$(date +'%Y-%m-%d_%H_%M').txt
if [ ! -d "$MAINDIR/${testname}" ]; then
    mkdir -p $MAINDIR/${testname}
fi


echo "Running Test:$test"
echo "Running Testname:$testname"
echo "Running Host:$host"
echo "Running Port:$port"
echo "Running Engine:$engine"
echo "Running Schemaname: $schemaname"
echo "Running Table: $tablename"


print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}

if [ "${engine}" == "pliops" ];
 then
  port=3307;
fi

nc -w 1 -z $host $port
if [ $? -ne 0 ] ; then
    echo "[ERROR] Mysql did not start correctly ($host : $port)" >> "${LOGFILE}"
  exit 1
else
  echo "[OK] Mysql running correctly" >> "${LOGFILE}"
fi




if [ $test == "sysbench" ] ;
 then
        echo "     Testing  $test $(print_date_time) [START]" >> "${LOGFILE}"
    cd /opt/tools/sysbench

        for threads in $THREADS;do
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [Start] $(print_date_time) "

                echo "RUNNING Test $test READ ONLY Thread=$threads [START] $(print_date_time) " >> "${LOGFILE}"
                echo "======================================" >>  "${LOGFILE}"
                sysbench /opt/tools/sysbench/src/lua/padding/oltp_read.lua  --mysql-host=$host --mysql-port=$port --mysql-user=$USER --mysql-password=$PW --mysql-db=$schemaname --db-driver=mysql --tables=$TABLES --table_size=$ROWS  --time=$TIME  --rand-type=zipfian --rand-zipfian-exp=0 --skip_trx=on  --report-interval=1 --mysql-ignore-errors=none  --auto_inc=off --histogram --table_name=$tablename  --stats_format=csv --db-ps-mode=disable --threads=$threads run >> "${LOGFILE}"
                echo "======================================" >> "${LOGFILE}"
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) " >> "${LOGFILE}"
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) "
        done;
    cd /opt/tools
        echo "Testing  $test $(date +'%Y-%m-%d_%H_%M_%S') [END]" >> "${LOGFILE}";
fi


if [ $test == "sysbench_rw" ] ;
 then
        echo "     Testing  $test $(print_date_time) [START]" >> "${LOGFILE}"
    cd /opt/tools/sysbench

        for threads in $THREADS;do
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [Start] $(print_date_time) "
                echo "RUNNING Test $test OLTP Thread=$threads [START] $(print_date_time) " >> "${LOGFILE}"
                echo "======================================" >>  "${LOGFILE}"
                sysbench /opt/tools/sysbench/src/lua/padding/oltp_read_write.lua  --mysql-host=$host --mysql-port=$port --mysql-user=$USER --mysql-password=$PW --mysql-db=$schemaname --db-driver=mysql --tables=$TABLES --table_size=$ROWS  --time=$TIME  --rand-type=zipfian --rand-zipfian-exp=0 --skip_trx=on  --report-interval=1 --mysql-ignore-errors=nonr  --auto_inc=on --histogram --table_name=$tablename  --stats_format=csv --db-ps-mode=disable --threads=$threads run >> "${LOGFILE}"
                echo "======================================" >> "${LOGFILE}"
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) " >> "${LOGFILE}"
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) "

        done;
    cd /opt/tools
        echo "Testing  $test $(date +'%Y-%m-%d_%H_%M_%S') [END]" >> "${LOGFILE}";
fi

if [ $test == "tpcc" ] ;
 then
    cd /opt/tools/sysbench-tpcc
        echo "     Testing  $test $(print_date_time) [START]">> "${LOGFILE}"

        for threads in $THREADS;do
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [Start] $(print_date_time) "
                echo "RUNNING Test $test Thread=$threads [START] $(print_date_time) " >>  "${LOGFILE}"
                echo "======================================" >>  "${LOGFILE}"
                sysbench /opt/tools/sysbench-tpcc/tpcc.lua --mysql-host=$host --mysql-port=$port --mysql-user=$USER --mysql-password=$PW --mysql-db=tpcc --db-driver=mysql --tables=$WAREHOUSES --scale=$SCALE --time=$TIME  --rand-type=zipfian --rand-zipfian-exp=0 --report-interval=1 --mysql-ignore-errors=all --histogram  --stats_format=csv --db-ps-mode=disable --threads=$threads run  >>  "${LOGFILE}"
                echo "======================================" >>  "${LOGFILE}"
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) " >>  "${LOGFILE}"
                echo "======================================" 
                echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) "

        done;
        echo "Testing  $test $(date +'%Y-%m-%d_%H_%M_%S') [END]" >>  "${LOGFILE}" ;
    cd /opt/tools
fi


