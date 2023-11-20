#!/bin/bash
#./run_bench_tests.sh runPS8034 sysbench 127.0.0.1 point_select windmills_large  

#globals
declare -A sysbench_tests
declare -A ingest_tests 
declare -A tpcc_tests 

#setting defaults
test="testXYZ"
testname="sysbench"
host="127.0.0.1"
port=3306
subtest="all"
schemaname="windmills_small"
engine="innodb"
tablename="mills"
debug=false
command_list=false

#constants
RESULTS=/opt/results
#TIME=60
TIME=1200
TABLES_SMALL=20
ROWS_SMALL=10000000
TABLES_LARGE=5
ROWS_SMALL=30000000
WHAREHOUSES=100
TPCc_TABLES=10
#THREADS="32 64 92"
THREADS="1 2 4 8 16 32 64 128 256 512 1024 2056"
USER="app_test"
PW="test"

SYSBENCH_LUA="/opt/tools/sysbench"
TPCC_LUA="/opt/tools/sysbench-tpcc"


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --test)
            test="$2"
            shift 2
            ;;
        --testname)
            testname="$2"
            shift 2
            ;;
        --subtest)
            subtest="$2"
            shift 2
            ;;
        --schemaname)
            schemaname="$2"
            shift 2
            ;;
        --engine)
            engine="$2"
            shift 2
            ;;
        --tablename)
            tablename="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --port)
            port=$2
            shift
            ;;
        --debug)
            debug=true
            shift
            ;;
        --command_list)
            command_list=true
            shift
            ;;            
        *)
            echo "Unknown argument: $1"
                        echo "Usage: $0 --test <test Identifier> --testname <sysbench|tpcc|ingest> --subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --command_list]"
            exit 1
            ;;
    esac


LOGFILE=$RESULTS/${testname}/${test}_${subtest}_${engine}_$(date +'%Y-%m-%d_%H_%M').txt
if [ ! -d "$RESULTS/${testname}" ]; then
    mkdir -p $RESULTS/${testname}
fi


echo "Running Test: $test"
echo "Running Testname: $testname"
echo "Running Sub Test: $subtest"
echo "Running Host: $host"
echo "Running Port: $port"
echo "Running Engine: $engine"
echo "Running Schemaname: $schemaname"
echo "Running Table: $tablename"

echo "============= SysBench ============="
echo "Rows Small: $ROWS_SMALL"
echo "Tables Small: $TABLES_SMALL"
echo "Rows Large: $ROWS_LARGE"
echo "Tables Large: $TABLES_LARGE"

echo "============= TPC-C ============="
echo "Warehouses:  $WHAREHOUSES"
echo "Tables: $TPCc_TABLES"

print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}

nc -w 1 -z $host $port
if [ $? -ne 0 ] ; then
    echo "[ERROR] Mysql did not start correctly ($host : $port)"
    echo "[ERROR] Mysql did not start correctly ($host : $port)" >> "${LOGFILE}"
#  exit 1
else
  echo "[OK] Mysql running correctly" 
  echo "[OK] Mysql running correctly" >> "${LOGFILE}"
fi

. $(dirname "$0")/fill_ingest_map.sh
. $(dirname "$0")/fill_sysbench_map.sh
. $(dirname "$0")/fill_tpcc_map.sh


fill_ingest_map
fill_sysbench_map 
fill_tpcc_map 

if [ "$debug" = true ]; then 

    for key in "${!ingest_tests[@]}"; do
        echo "Key: $key Value: ${ingest_tests[$key]}"
    done


    for key in "${!sysbench_tests[@]}"; do
        echo "Key: $key Value: ${sysbench_tests[$key]}"
    done

    for key in "${!tpcc_tests[@]}"; do
        echo "Key: $key Value: ${tpcc_tests[$key]}"
    done
fi

if [ "$command_list" = true ]; then 
    echo "-- Ingest --"
    sorted=`echo ${!ingest_tests[@]}|sort`
    for key in $sorted; do
        echo "Sub Test: $key "
    done

    echo "-- Sysbench --"
    sorted=`echo ${!sysbench_tests[@]} |sort`
    for sorted in $sorted; do
        echo "Sub Test: $key "
    done
    echo "-- Tpcc --"
    sorted=`echo ${!tpcc_tests[@]} |sort`
    for key in $sorted; do
        echo "Sub Test: $key "
    done
fi
exit



if [ $test == "sysbench" ] ;
 then
        echo "     Testing  $test $subtest $(print_date_time) [START]" >> "${LOGFILE}"
    cd $SYSBENCH_LUA

        for threads in $THREADS;do
                echo "======================================" 
                echo "RUNNING Test $test $subtest Thread=$threads [Start] $(print_date_time) "

                echo "RUNNING Test $test $subtest  Thread=$threads [START] $(print_date_time) " >> "${LOGFILE}"
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
