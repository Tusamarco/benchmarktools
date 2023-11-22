#!/bin/bash
#./run_bench_tests.sh runPS8034 sysbench 127.0.0.1 point_select windmills_large  

. $(dirname "$0")/help.sh

#globals
declare -A sysbench_tests
declare -A ingest_tests 
declare -A tpcc_tests 
declare -a execute_map

#setting defaults
command="run"
debug=false
dryrun=false
engine="innodb"
filter_subtest="none"
help=false
host="127.0.0.1"
port=3306
schemaname="windmills_"
subtest_list=false
subtest="all"
table_name="mills"
test="testXYZ"
testname="sysbench"
sysbench_test_dimension="small"
sysbench_tables=""
sysbench_rows=""


#constants
PW="test"
RESULTS=/opt/results
SYSNBENCH_ROWS_SMALL=10000000
SYSNBENCH_ROWS_LARGE=30000000
SYSNBENCH_TABLES_LARGE=5
SYSNBENCH_TABLES_SMALL=20
THREADS="1 2"
#THREADS="1 2 4 8 16 32 64 128 256 512 1024 2056"
TIME=60
TPCc_TABLES=10
USER="app_test"
WHAREHOUSES=100

SYSBENCH_LUA="/opt/tools/sysbench"
TPCC_LUA="/opt/tools/sysbench-tpcc"
LOCAL_PATH="`pwd`"


#operative variables
subtest_execute="";


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --command)
            command="$2"
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
       --filter_subtest)
            filter_subtest="$2"
            shift 2
            ;;
        --TIME)
            TIME="$2"
            shift 2
            ;;
        --THREADS)
            THREADS="$2"
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
            table_name="$2"
            shift 2
            ;;
        --host)
            host="$2"
            shift 2
            ;;
        --port)
            port=$2
            shift 2
            ;;
        --sysbench_test_dimension)
            sysbench_test_dimension="$2"
            shift 2
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
        --dryrun)
            dryrun=true
            shift 
            ;;
        *)
            echo "Unknown argument: $1"
			helptext
            exit 1
            ;;
    esac
done;

. $(dirname "$0")/fill_ingest_map.sh
. $(dirname "$0")/fill_sysbench_map.sh
. $(dirname "$0")/fill_tpcc_map.sh
. $(dirname "$0")/sub_test_mgm.sh




#local functions
#========================================
print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}



#========================================


if [ "$help" == true ]; then
	helptext
fi

if [ "$sysbench_test_dimension" == "small" ]; then
    sysbench_tables="$SYSNBENCH_TABLES_SMALL"
    sysbench_rows="$SYSNBENCH_ROWS_SMALL"
 else
    sysbench_tables="$SYSNBENCH_TABLES_LARGE"
    sysbench_rows="$SYSNBENCH_ROWS_LARGE"
fi





LOGFILE=$RESULTS/${testname}/${test}_${command}_${subtest}_${filter_subtest}_${engine}_$(date +'%Y-%m-%d_%H_%M').txt
if [ ! -d "$RESULTS/${testname}" ]; then
    mkdir -p $RESULTS/${testname}
fi

echo "Current path: $LOCAL_PATH"
echo "Dry run: ${dryrun}"
echo "Running Test: $test"
echo "Running Testname: $testname"
echo "Running Sub Test: $subtest"
echo "Running Host: $host"
echo "Running Port: $port"
echo "Running Engine: $engine"
echo "Running Schemaname: $schemaname"
echo "Running Table: $table_name"
echo "Running TIME: $TIME"
echo "Running Thread set: $THREADS"

echo "============= SysBench ============="
echo "Rows Small: $SYSNBENCH_ROWS_SMALL"
echo "Tables Small: $SYSNBENCH_TABLES_SMALL"
echo "Rows Large: $SYSNBENCH_ROWS_LARGE"
echo "Tables Large: $SYSNBENCH_TABLES_LARGE"
echo "Using: ${sysbench_test_dimension}"
echo "Tables: ${sysbench_tables}"
echo "Rows:   ${sysbench_rows}"
echo "============= TPC-C ============="
echo "Warehouses:  $WHAREHOUSES"
echo "Tables: $TPCc_TABLES"



nc -w 1 -z $host $port
if [ $? -ne 0 ] ; then
    echo "[ERROR] Mysql did not start correctly ($host : $port)"
    if [ ! "$dryrun" == "true" ]; then
	    echo "[ERROR] Mysql did not start correctly ($host : $port)" >> "${LOGFILE}"
	fi
#  exit 1
else
  echo "[OK] Mysql running correctly" 
  if [ ! "$dryrun" == "true" ]; then
	  echo "[OK] Mysql running correctly" >> "${LOGFILE}"
  fi
fi

fill_ingest_map
fill_sysbench_map 
fill_tpcc_map 

if [ "$subtest_list" = true ]; then
    get_sub_test_txt 
    exit;
fi


#=========================
# Run Tests 
#=========================
run_tests(){
 label="$1"
 commandtxt="$2"

 if [ "$dryrun" == "true" ]; then
      echo "Label: $label"
      echo "Command: ${commandtxt}  --time=$TIME  --threads=${THREADS} $command "
 	else
 	 echo "nothing to do"
 fi


# if [ $testname == "sysbench" ] ;
#  then
#         echo "     Testing  $test $(print_date_time) [START]" >> "${LOGFILE}"
#     cd /opt/tools/sysbench
# 
#         for threads in $THREADS;do
#                 echo "======================================" 
#                 echo "RUNNING Test $test Thread=$threads [Start] $(print_date_time) "
# 
#                 echo "RUNNING Test $test READ ONLY Thread=$threads [START] $(print_date_time) " >> "${LOGFILE}"
#                 echo "======================================" >>  "${LOGFILE}"
#                 sysbench /opt/tools/sysbench/src/lua/padding/oltp_read.lua  --mysql-host=$host --mysql-port=$port --mysql-user=$USER --mysql-password=$PW --mysql-db=$schemaname --db-driver=mysql --tables=$TABLES --table_size=$ROWS  --time=$TIME  --rand-type=zipfian --rand-zipfian-exp=0 --skip_trx=on  --report-interval=1 --mysql-ignore-errors=none  --auto_inc=off --histogram --table_name=$tablename  --stats_format=csv --db-ps-mode=disable --threads=$threads run >> "${LOGFILE}"
#                 echo "======================================" >> "${LOGFILE}"
#                 echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) " >> "${LOGFILE}"
#                 echo "======================================" 
#                 echo "RUNNING Test $test Thread=$threads [END] $(print_date_time) "
#         done;
#     cd /opt/tools
#         echo "Testing  $test $(date +'%Y-%m-%d_%H_%M_%S') [END]" >> "${LOGFILE}";
# fi

















}

#get list of subtests to run (and commands)
if [ "$subtest" == "all" ] && [ ! "$testname" == "all" ]; then
     get_sub_test
    # echo "$subtest_execute"

 elif [ ! "$subtest" == "all" ] && [ "$testname" == "all" ]; then
      echo "You cannot run all the different test types at once (ingest|sysbench|tpcc)"
	  exit;
 else
      	echo "You need to pick eiter a set of subtests or"  
fi

if [ ! "$dryrun" == "true" ]; then 
	if [ $testname == "sysbench" ] || [ $testname == "ingest" ] ; then
		`cd $SYSBENCH_LUA`
	  elif [ $testname == "ingest" ]; then   
		`cd $SYSBENCH_LUA`
	  elif [ $testname == "tpcc" ]; then 
		`cd $TPCC_LUA`  
	  else 
		`cd $LOCAL_PATH`  
	fi
fi

#get the final execute_map
if [ $testname == "sysbench" ]; then
	for subtest_run in $subtest_execute;do	
        run_tests "${subtest_run}" "${sysbench_tests[$subtest_run]} --tables=${sysbench_tables} --table_size=${sysbench_rows} "
	done;
fi

if [ $testname == "ingest" ]; then
	for subtest_run in $subtest_execute;do	
		 run_tests "$subtest_run" "${ingest_tests[$subtest_run]}"
	done;
fi

if [ $testname == "tpcc" ]; then
	for subtest_run in $subtest_execute;do	
		run_tests "$subtest_run" "${tpcc_tests[$subtest_run]}"
	done;
fi


exit



