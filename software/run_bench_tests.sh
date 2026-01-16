#!/bin/bash



#./run_bench_tests.sh runPS8034 sysbench 127.0.0.1 point_select windmills_large  

#globals
declare -A sysbench_tests
declare -A ingest_tests 
declare -A tpcc_tests 
declare -A join_tests
declare -a execute_map

#setting defaults
actionType=""
command="run"
debug=false
dryrun=false
engine="innodb"
error_ignore="none"
filter_subtest="none"
havePMM=false
haveperf="false"
help=false
host="127.0.0.1"
pmmservicename=""
pmmurl=""
port=3306
rate=""
reconnect="0"
run="1"
schemaname="windmills_small"
sleep_wait=5
subtest_list=false
subtest="all"
sysbench_rows=""
sysbench_tables=""
sysbench_test_dimension="small"
table_name="mill"
test="testXYZ"
testname="sysbench"
testrun=false
type=""
events=0

#constants
FLAMEGRAPHPATH="/opt/tools/FlameGraph/"
JOINS_MAIN_TABLES=10
JOINS_ROWS_PER_TABLE=100000
# JOINS_ROWS_PER_TABLE=10000000
JOINS_ACTIVE_LEVELS=5
LOCAL_PATH="`pwd`"
MAX_THREADS_RUNNING_BETWEEN_TESTS=20
MYSQL_COMMENT=""
MYSQL_VERSION=""
PW="test"
RESULTS=/opt/results
SYSBENCH_LUA="/opt/tools/sysbench"
SYSBENCH_LUA_TPCC="/opt/tools/sysbench-tpcc"
SYSNBENCH_ROWS_LARGE=30000000
SYSNBENCH_ROWS_SMALL=10000000
SYSNBENCH_TABLES_LARGE=5
SYSNBENCH_TABLES_SMALL=20
#THREADS="1 2 4 8 16 32 64 128 256 512 1024 2056"
THREADS="1 2"
TIME=60
TPCC_LUA="/opt/tools/sysbench-tpcc"
TPCc_TABLES=10
USER="app_test"
WHAREHOUSES=100

#Import Help
. $(dirname "$0")/help.sh

#operative variables
subtest_execute="";


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        "") 
            shift 
            ;;
        --user)
           USER="$2"
           shift 2
           ;;
        --password)
           PW="$2"
           shift 2
           ;;
        --rate)
           rate="$2"
           shift 2
           ;;
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
        --type)
            type="$2"
            shift 2
            ;;
        --run)
            run="$2"
            shift 2
            ;;    
       --filter_subtest)
            filter_subtest="$2"
            shift 2
            ;;
        --time)
            TIME="$2"
            shift 2
            ;;
        --threads)
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
        --reconnect)
            reconnect="$2"
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
        --error_ignore)
            error_ignore="$2"
            shift 2
            ;;
        --events)
            events="$2"
            shift 2
            ;;  
        --havePMM)
            havePMM=true
            shift
            ;;
        --pmm_url)
            pmmurl="$2"
            shift 2
            ;;     
        --pmm_node_name)
            pmmnodename="$2"
            shift 2
            ;;
        --pmm_service_name)
            pmmservicename="$2"
            shift 2
            ;;  
        --joins_active_levels)
            JOINS_ACTIVE_LEVELS="$2"
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
        --haveperf)
            haveperf=true
            shift 
            ;;
        --testrun)
            testrun=true
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
. $(dirname "$0")/fill_joins.sh
. $(dirname "$0")/sub_test_mgm.sh




#local functions
#========================================
print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}

check_pmm(){

pmmOK=`curl  -Isk ${pmmurl}/graph |grep HTTP|awk -F " " '{print $2}'`

if [ ! "$pmmOK" = "200"  ]; then
  havePMM=false
  echo "[WARNING] PMM is not correctly set, automatic notation disabled" | tee -a $LOGFILE
 else 
    test -x "$(which pmm-admin)"
    if [ $? -ne 0 ]; then
    	    echo "[WARNING] PMM client not installed. please add pmm2-client before trying to use it" | tee -a $LOGFILE
    	    havePMM=false
    	    echo "[WARNING] PMM is not correctly set, automatic notation disabled" | tee -a $LOGFILE
    else
	    echo "[INFO] PMM is correctly set, automatic notation enabled" | tee -a $LOGFILE
    fi
fi

}

check_flamegraph(){
local failing=false
 
	if [ ! command -v perf &> /dev/null ];then
	    echo "[ERROR][FLAME Graph check] The perf command is not present or cannot be found" | tee -a $LOGFILE
    	failing=true
      else
	    echo "[INFO][FLAME Graph check] The perf command is present" | tee -a $LOGFILE
	fi
	
	
	if [ "$haveperf" == "true" ]; then
		if [ -f "${FLAMEGRAPHPATH}/stackcollapse-perf.pl" ]; then
			echo '[INFO][FLAME Graph check] The file for FlameGraph ${${FLAMEGRAPHPATH}/stackcollapse-perf.pl} exists.' | tee -a $LOGFILE
		else
			echo '[ERROR][FLAME Graph check] The file for FlameGraph ${${FLAMEGRAPHPATH}/stackcollapse-perf.pl} does not exist. Wrong Path?'| tee -a $LOGFILE
	    	failing=true		
	    fi	
	fi

if [ "$failing" == true ]; then
	exit 1
fi
	
}
#===========================
# Check for running process
#===========================
get_mysql_process_count() {
    local db_user="${1:-app_test}"
    local db_pass="${2:-test}"
    local db_host="${3:-127.0.0.1}"
    local db_port="${4:-3306}"
    local db_name="performance_schema"
    
    # Execute query
    local result=$(MYSQL_PWD="$db_pass" mysql -u ${db_user} -h $db_host -P $db_port $db_name -e "SELECT COUNT(*) FROM processlist;" --batch --skip-column-names 2>&1)
    
    # Check if command succeeded
    if [ $? -ne 0 ]; then
        echo "ERROR: $result" >&2
        return 1
    fi
    
    # Verify we got a numeric result
    if ! [[ "$result" =~ ^[0-9]+$ ]]; then
        echo "ERROR: Invalid result received: '$result'" >&2
        return 1
    fi
    
    echo "$result"
    return 0
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

if [ "$testrun" == "true" ];then
    test="${test}_TESTRUN"
fi 

if [ $testname == "sysbench" ] || [ $testname == "ingest" ] ; then
	actionType=$type
  elif [ $testname == "tpcc" ] || [ $testname == "joins" ]; then 
	actionType="read/write"
  else 
	actionType=$type
fi

RUNNINGDATE="$(date +'%Y-%m-%d_%H_%M')"
LOGFILE=$RESULTS/${testname}/${test}_${sysbench_test_dimension}_${type}_runNumber${run}_${command}_${filter_subtest}_${engine}_${RUNNINGDATE}.txt
PERFREPORT=$RESULTS/${testname}/PERF_REPORT_${test}_${sysbench_test_dimension}_${type}_runNumber${run}_${command}_${filter_subtest}_${engine}

if [ ! -d "$RESULTS/${testname}" ]; then
    mkdir -p $RESULTS/${testname}
fi

if [ "$dryrun" == "true" ]; then
   LOGFILE=/dev/null 
fi

check_pmm
check_flamegraph

echo "Current path: $LOCAL_PATH" | tee -a $LOGFILE
echo "Execution time: ${RUNNINGDATE}" | tee -a $LOGFILE
echo "Sysbench Command: ${command}"  | tee -a $LOGFILE
echo "Test: $test"  | tee -a $LOGFILE
echo "Testname: $testname"  | tee -a $LOGFILE
# echo "Sub Test: $subtest"  | tee -a $LOGFILE
echo "Host: $host"  | tee -a $LOGFILE
echo "Port: $port"  | tee -a $LOGFILE
echo "Engine: $engine"  | tee -a $LOGFILE
echo "Schemaname: $schemaname"  | tee -a $LOGFILE
echo "Table: $table_name"  | tee -a $LOGFILE
echo "TIME: $TIME"  | tee -a $LOGFILE
echo "Thread set: $THREADS"  | tee -a $LOGFILE
echo "Rate set: $rate"  | tee -a $LOGFILE
echo "Ignore error set: $error_ignore"  | tee -a $LOGFILE
echo "TESTRUN: $testrun"  | tee -a $LOGFILE
echo "Have PMM notation: $havePMM"  | tee -a $LOGFILE
echo "Use FlameGraph (collect perf report): $haveperf"  | tee -a $LOGFILE
#echo "META: testIdentifyer=${test};dimension=${sysbench_test_dimension};actionType=${actionType};runNumber=${run};host=$host;producer=${testname};execDate=${RUNNINGDATE};engine=${engine}" | tee -a "${LOGFILE}";
if [ $testname == "sysbench" ]; then
	echo "============= SysBench ============="  | tee -a $LOGFILE
	echo "Rows Small: $SYSNBENCH_ROWS_SMALL"  | tee -a $LOGFILE
	echo "Tables Small: $SYSNBENCH_TABLES_SMALL"  | tee -a $LOGFILE
	echo "Rows Large: $SYSNBENCH_ROWS_LARGE"  | tee -a $LOGFILE
	echo "Tables Large: $SYSNBENCH_TABLES_LARGE"  | tee -a $LOGFILE
	echo "Using: ${sysbench_test_dimension}"  | tee -a $LOGFILE
	echo "Tables: ${sysbench_tables}"  | tee -a $LOGFILE
	echo "Rows:   ${sysbench_rows}"  | tee -a $LOGFILE
fi

if [ $testname == "tpcc" ]; then
	echo "============= TPC-C ============="  | tee -a $LOGFILE
	echo "Warehouses:  $WHAREHOUSES"  | tee -a $LOGFILE
	echo "Tables: $TPCc_TABLES"  | tee -a $LOGFILE
fi

if [ $testname == "joins" ]; then
	echo "============= SysBench ============="  | tee -a $LOGFILE
	echo "Rows for join test: $JOINS_ROWS_PER_TABLE"  | tee -a $LOGFILE
	echo "Tables Main: $JOINS_MAIN_TABLES"  | tee -a $LOGFILE
	echo "Max Levels: 5"  | tee -a $LOGFILE
    echo "Active Levels: ${JOINS_ACTIVE_LEVELS}"  | tee -a $LOGFILE
fi


fill_ingest_map
fill_sysbench_map 
fill_tpcc_map 
fill_joins_map

#setting rate
if [ ! "$rate" == "" ];then
   rate="--rate=${rate}" 
fi

if [ ! "$events" == "" ] && [ ! "$events" == "0" ];then
    events="--events=${events}"
    TIME=0
    echo "NOTE: Events is active events=${events}, TIME will be disabled TIME=${TIME}"  | tee -a $LOGFILE
else
    echo "NOTE: Events is NOT active events=${events}, Using TIME,  TIME=${TIME}"  | tee -a $LOGFILE
fi


if [ ! "$subtest_list" == "true" ]; then
	nc -w 1 -z $host $port
	
	if [ $? -ne 0 ]; then
		 echo "[ERROR] Mysql did not start correctly ($host : $port)" | tee -a $LOGFILE
		 exit 1
	else
	     mysql_version_comment=`mysql -u $USER -p$PW -h $host -P $port -BN -e "select concat(@@version_comment,\";\",@@version)" 2> /dev/null` 
	     if [ ! "mysql_version_comment" == "" ]; then
	         IFS=';'
	         read -ra mysql_var <<< "$mysql_version_comment"
	         MYSQL_VERSION="mysqlversion=${mysql_var[1]}"
	         MYSQL_COMMENT="mysqlproducer=${mysql_var[0]}"
             IFS=' ' 
	         echo "MySQL Provider ${MYSQL_COMMENT} Version: ${MYSQL_VERSION}" | tee -a $LOGFILE
	     fi
		 echo "[OK] Mysql running correctly  " | tee -a $LOGFILE
	fi
  else
      get_sub_test_txt 
      exit;
fi
echo "META: ${MYSQL_COMMENT};${MYSQL_VERSION};testIdentifyer=${test};dimension=${sysbench_test_dimension};actionType=${actionType};runNumber=${run};host=$host;producer=${testname};execDate=${RUNNINGDATE};engine=${engine}" | tee -a "${LOGFILE}";


#=========================
# Run Tests 
#=========================
run_tests(){
 label="$1"
 commandtxt="$2"
 max_threads=0
 local_perf_report=""

 # Set join test dimension
 join_test_dimension=""

  if [ $testname == "joins" ] ; then
    sysbench_tables=$JOINS_MAIN_TABLES
    sysbench_rows=$JOINS_ROWS_PER_TABLE

    join_test_dimension="--join_levels=${JOINS_ACTIVE_LEVELS}"
 fi

	echo "*****************************************" | tee -a  "${LOGFILE}";
	echo "SUBTEST: $label" | tee -a "${LOGFILE}";
	echo "BLOCK: [START] $label Test $test $testname  (filter: ${filter_subtest}) $(date +'%Y-%m-%d_%H_%M_%S') " | tee -a "${LOGFILE}";
	echo "META: testIdentifyer=${test};dimension=${sysbench_test_dimension};actionType=${actionType};runNumber=${run};execCommand=$command;subtest=${label};execDate=$(date +'%Y-%m-%d_%H_%M_%S');engine=${engine};${MYSQL_COMMENT};${MYSQL_VERSION}" | tee -a "${LOGFILE}";
	if [[ $commandtxt =~ "--launcher_threads_override" ]]; then
        	commandtxt=$(echo $commandtxt| sed -e 's/--launcher_threads_override//gi') 
        	max_threads=$sysbench_tables
        	echo "NOTE: launcher_threads_override detected, threads set to do not exceed: $max_threads" | tee -a  "${LOGFILE}"
	fi

	if [ "$testrun" == "true" ];then
        THREADS="1"
        TIME=5
        havePMM=false	
	fi
	
	if [ "$command" == "cleanup" ]; then
        THREADS=$sysbench_tables
	fi
	
	if [ "$havePMM" == "true" ]; then
		if [ ! "$pmmservicename" == "" ]; then
		     pmmservicenameTag="--service-name=$pmmservicename"
		fi
	
	    pmm-admin annotate "[START] Test: ${test} $label $(date +'%Y-%m-%d_%H_%M_%S')" --node --node-name=${pmmnodename} ${pmmservicenameTag} --server-url=${pmmurl}  --tags "$testname"
	   	if [ $? -ne 0 ]; then
			 echo "[WARNING] PMM annotatione failed, check syntax" | tee -a $LOGFILE
 			 echo "   Command used: pmm-admin annotate \"[START] $label Test: $test $testname  (filter: ${filter_subtest}) $(date +'%Y-%m-%d_%H_%M_%S')\" --node --node-name=${pmmnodename} ${pmmservicenameTag} --server-url=${pmmurl}  --tags \"$testname\" " | tee -a $LOGFILE
 			 havePMM=false
             echo "PMM notation disabled" | tee -a $LOGFILE 
		fi
		
	fi
	
	if [ "$haveperf" == "true" ]; then
	    local_perf_report="${PERFREPORT}_${label}_$(date +'%Y-%m-%d_%H_%M_%S')"
		sudo perf record -a -F 99 -g -p $(pgrep -x mysqld) -o  ${local_perf_report} &
	fi
	
	for threads in $THREADS;do
	  if [ $max_threads -gt 0 ] && [ $threads -gt $max_threads ]; then
		    echo "max_threads hit we are skipping threads: $threads" | tee -a "${LOGFILE}" 
		   continue; 
	   else 
			echo "======================================"  | tee -a  "${LOGFILE}"
			echo "THREADS=$threads" | tee -a  "${LOGFILE}"
			echo "RUNNING Test $test $testname $label (filter: ${filter_subtest}) Thread=$threads [START] $(print_date_time) " | tee -a "${LOGFILE}"
			echo "======================================" | tee -a  "${LOGFILE}"

            if [ $testname == "joins" ] ; then
                echo "RUNNING Joins test; set EVENTS=THREADS events=$threads" | tee -a  "${LOGFILE}"    
			    echo "======================================" | tee -a  "${LOGFILE}"                
                events="--events=${threads}"
                TIME=0
            fi

            if [ "$command" == "warmup" ] || [ "$command" == "cleanup" ]; then
                    echo "Executing: ${commandtxt} --threads=${threads} --mysql-ssl=PREFERRED --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} ${join_test_dimension} $command " | tee -a "${LOGFILE}"

                    if [ ! "$dryrun" == "true" ]; then
                    ${commandtxt} --threads=${threads} --mysql-ssl=PREFERRED --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} ${join_test_dimension} $command  | tee -a "${LOGFILE}"
                fi
            else
                    echo "Executing: ${commandtxt}  --time=$TIME ${events} --threads=${threads} --mysql-ssl=PREFERRED --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} ${join_test_dimension} $command " | tee -a "${LOGFILE}"

                    if [ ! "$dryrun" == "true" ]; then
                        ${commandtxt}  --time=$TIME ${events} --threads=${threads} --mysql-ssl=PREFERRED --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} ${join_test_dimension} $command  | tee -a "${LOGFILE}"
                    fi
            fi
			echo "======================================" | tee -a "${LOGFILE}"
			echo "RUNNING Test $test $testname $label (filter: ${filter_subtest}) Thread=$threads [END] $(print_date_time) " |tee -a "${LOGFILE}"
			echo "======================================" 

            # We check if there are too many process running, in that case we will wait for the resoirces to free up
            if [ ! "$dryrun" == "true" ]; then
                sleep 5
                process_count=$(get_mysql_process_count "$USER" "$PW" "$host" "$port")
    #echo "DEBUG!!!!!!!!!!! $process_count"
                while [ "$process_count" -gt $MAX_THREADS_RUNNING_BETWEEN_TESTS ]
                do
                    echo "WARNING ============== TOO MANY Process running {$process_count}" | tee -a "${LOGFILE}"
                    echo "WARNING ============== Check what is using resources we will wait $sleep_wait then retry " | tee -a "${LOGFILE}"
                    sleep $sleep_wait
                    process_count=$(get_mysql_process_count "$USER" "$PW" "$host" "$port")
                done;
                
                echo "INFO ============== ALL good we have {$process_count} process running, continue to test" | tee -a "${LOGFILE}"
            fi
	  fi
	done;

	if [ "$haveperf" == "true" ]; then
			sudo kill -SIGINT  $(pgrep -x perf) | tee -a "${LOGFILE}"    
			sleep 5
			perf script -i ${local_perf_report} > ${local_perf_report}.script  | tee -a "${LOGFILE}"   
			${FLAMEGRAPHPATH}/stackcollapse-perf.pl ${local_perf_report}.script | ${FLAMEGRAPHPATH}/flamegraph.pl > ${local_perf_report}.svg 
			rm -f ${local_perf_report} | tee -a "${LOGFILE}" 
			rm -f ${local_perf_report}.script | tee -a "${LOGFILE}" 
			echo "Flame Graph for $label generated: ${local_perf_report}.svg" | tee -a "${LOGFILE}" 
	fi


	if [ "$havePMM" = "true" ]; then
	    pmm-admin annotate "[END] $test $label $(date +'%Y-%m-%d_%H_%M_%S')" --node --node-name=${pmmnodename} ${pmmservicenameTag} --server-url=${pmmurl}  --tags "$testname"
	   	if [ $? -ne 0 ]; then
			 echo "[WARNING] PMM annotatione failed, check syntax" | tee -a $LOGFILE
 			 echo "   Command used: pmm-admin annotate \"[END] $test $label Test $test $testname  (filter: ${filter_subtest}) $(date +'%Y-%m-%d_%H_%M_%S')\" --node --node-name=${pmmnodename} ${pmmservicenameTag} --server-url=${pmmurl}  --tags \"$testname\" " | tee -a $LOGFILE
 			 havePMM=false
             echo "PMM notation disabled" | tee -a $LOGFILE 
		fi
	fi

	echo "BLOCK: [END] $label Test $test $testname  (filter: ${filter_subtest}) $(date +'%Y-%m-%d_%H_%M_%S') " | tee -a  "${LOGFILE}";
	echo "*****************************************" | tee -a  "${LOGFILE}";
	echo "" | tee -a  "${LOGFILE}";
}

#get list of subtests to run (and commands)
if [ ! "$testname" == "all" ]; then
     get_sub_test
    # echo "$subtest_execute"

 elif [ ! "$subtest_list" == "true" ] && [ "$testname" == "all" ]; then
      echo "You cannot run all the different test types at once (ingest|sysbench|tpcc|joins). Please pick one at a time."
	  exit;
 elif [ "$subtest_list" == "true" ] && [ "$testname" == "all" ]; then
     get_sub_test
     # echo "$subtest_execute"
 else
      	echo "You need to pick either a set of subtests or a testname  (ingest|sysbench|tpcc|joins)"  
      	exit; 
fi

if [ ! "$dryrun" == "true" ]; then 
	if [ $testname == "sysbench" ] || [ $testname == "ingest" ] ; then
		cd $SYSBENCH_LUA
	  elif [ $testname == "ingest" ]; then   
		cd $SYSBENCH_LUA
	  elif [ $testname == "tpcc" ]; then 
		cd $TPCC_LUA
      elif [ $testname == "joins" ]; then
        cd $SYSBENCH_LUA  
	  else 
		cd $LOCAL_PATH  
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

if [ $testname == "joins" ]; then
	for subtest_run in $subtest_execute;do	
		run_tests "$subtest_run" "${join_tests[$subtest_run]} --tables=${JOINS_MAIN_TABLES} --table_size=${JOINS_ROWS_PER_TABLE}  "
	done;
fi

#push end time info
echo "METACOLLECTION: enddate=$(date +'%Y-%m-%d_%H_%M_%S')" | tee -a $LOGFILE
#reset path
cd $LOCAL_PATH
exit



