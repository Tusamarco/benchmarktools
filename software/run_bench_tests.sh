#!/bin/bash
#./run_bench_tests.sh runPS8034 sysbench 127.0.0.1 point_select windmills_large  

#globals
declare -A sysbench_tests
declare -A ingest_tests 
declare -A tpcc_tests 

#setting defaults
command="run"
debug=false
dryrun=false
engine="innodb"
help=false
host="127.0.0.1"
port=3306
schemaname="windmills_small"
subtest_list=false
subtest="all"
tablename="mills"
test="testXYZ"
testname="sysbench"


#constants
PW="test"
RESULTS=/opt/results
ROWS_SMALL=10000000
ROWS_SMALL=30000000
TABLES_LARGE=5
TABLES_SMALL=20
THREADS="1 2 4 8 16 32 64 128 256 512 1024 2056"
#THREADS="32 64 92"
#TIME=1200
TIME=60
TPCc_TABLES=10
USER="app_test"
WHAREHOUSES=100

SYSBENCH_LUA="/opt/tools/sysbench"
TPCC_LUA="/opt/tools/sysbench-tpcc"


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --command)
            command="$2"
            shift 2
            ;;
        --dryrun)
            dryrun=true
            shift 2
            ;;
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
        --subtest_list)
            subtest_list=true
            shift
            ;;            
        --help)
            help=true
            shift
            ;;                        
        *)
            echo "Unknown argument: $1"
                        echo "Usage: $0 --test <test Identifier> --testname <sysbench|tpcc|ingest> --subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list]"
            exit 1
            ;;
    esac
done;

. $(dirname "$0")/fill_ingest_map.sh
. $(dirname "$0")/fill_sysbench_map.sh
. $(dirname "$0")/fill_tpcc_map.sh
. $(dirname "$0")/help.sh



#local functions
#========================================
print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}



#========================================


if [ "$help" = true ]; then
	help
fi


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



nc -w 1 -z $host $port
if [ $? -ne 0 ] ; then
    echo "[ERROR] Mysql did not start correctly ($host : $port)"
    echo "[ERROR] Mysql did not start correctly ($host : $port)" >> "${LOGFILE}"
#  exit 1
else
  echo "[OK] Mysql running correctly" 
  echo "[OK] Mysql running correctly" >> "${LOGFILE}"
fi

fill_ingest_map
fill_sysbench_map 
fill_tpcc_map 


print_subtest_key(){
sorted="$1"

	if [ "$command" == "cleanup" ] || [ "$command" == "prepare" ] || [ "$command" == "all" ]; then
		echo "-- cleanup prepare --"
		for key in ${sorted}; do
			if [[ "$key" =~ "clean" ]];then
				echo "   $key "
			fi
		done
	fi
	if [ "$command" == "run" ] || [ "$command" == "all" ]; then	
		echo "-- run --"
		for key in ${sorted}; do
			if ! [[ "$key" =~ "clean" ]];then
				echo "   $key "
			fi
		done
	fi	
}


get_sub_test(){
	if [ "$debug" == true ]; then
		echo $command
		echo $testname
	fi

    if [ "$testname" == "ingest" ] || [ "$testname" == "all" ]; then 
		echo "-- Ingest --"
		echo "SubTests:"
		sorted=`echo ${!ingest_tests[@]}|tr ' ' '\012' | sort| tr '\012' ' '`
		print_subtest_key "$sorted"
	fi	

    if [ "$testname" == "sysbench" ] || [ "$testname" == "all" ]; then 
		echo "-- Sysbench --"
		echo "SubTests:"
		sorted=`echo ${!sysbench_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key "$sorted"

    fi 

    if [ "$testname" == "tpcc" ] || [ "$testname" == "all" ]; then 
		echo "-- Tpcc --"
		echo "SubTests:"
		sorted=`echo ${!tpcc_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key "$sorted"
    fi

if [ "$debug" == true ]; then 
    echo "Full map value below (with commands)"
    echo "=========================================="
    for key in "${!ingest_tests[@]}"; do
        echo "Key: $key Value: ${ingest_tests[$key]}"
    done


    for key in "${!sysbench_tests[@]}"; do
        echo "Key: $key Value: ${sysbench_tests[$key]}"
    done

    for key in "${!tpcc_tests[@]}"; do
        echo "Key: $key Value: ${tpcc_tests[$key]}"
    done
    echo "=========================================="
fi

}


if [ "$subtest_list" = true ]; then
    get_sub_test 
fi

exit

#=========================
# Run Tests 
#=========================

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
