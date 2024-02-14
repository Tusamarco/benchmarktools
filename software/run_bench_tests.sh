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
schemaname="windmills_small"
subtest_list=false
subtest="all"
table_name="mill"
test="testXYZ"
testname="sysbench"
sysbench_test_dimension="small"
sysbench_tables=""
sysbench_rows=""
rate=""
error_ignore="none"
testrun=false
reconnect="0"
havePMM=false
pmmurl=""
pmmservicename=""
type=""
run="1"

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
        --type)
            type="$2"
            shift 2
            ;;
        --run)
            run="$2"
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
. $(dirname "$0")/sub_test_mgm.sh




#local functions
#========================================
print_date_time(){
 echo "$(date +'%Y-%m-%d_%H_%M_%S')"
}

check_pmm(){

pmmOK=`curl  -Is ${pmmurl}/graph |grep HTTP|awk -F " " '{print $2}'`

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

RUNNINGDATE="$(date +'%Y-%m-%d_%H_%M')"
LOGFILE=$RESULTS/${testname}/${test}_${sysbench_test_dimension}_${type}_runNumber${run}_${command}_${subtest}_${filter_subtest}_${engine}_${RUNNINGDATE}.txt
if [ ! -d "$RESULTS/${testname}" ]; then
    mkdir -p $RESULTS/${testname}
fi

if [ "$dryrun" == "true" ]; then
   LOGFILE=/dev/null 
fi

check_pmm

echo "Current path: $LOCAL_PATH" | tee -a $LOGFILE
echo "Execution time: ${RUNNINGDATE}" | tee -a $LOGFILE
echo "Dry run: ${dryrun}"  | tee -a $LOGFILE
echo "Test: $test"  | tee -a $LOGFILE
echo "Testname: $testname"  | tee -a $LOGFILE
echo "Sub Test: $subtest"  | tee -a $LOGFILE
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
echo "META: testIdentifyer=${test};dimension=${sysbench_test_dimension};actionType=${type};runNumber=${run};host=$host;producer=${testname};execDate=${RUNNINGDATE};engine=${engine}" | tee -a "${LOGFILE}";
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

echo "METACOLLECTION: startdate=${RUNNINGDATE}" | tee -a $LOGFILE
fill_ingest_map
fill_sysbench_map 
fill_tpcc_map 


if [ ! "$subtest_list" == "true" ]; then
	nc -w 1 -z $host $port
	if [ $? -ne 0 ]; then
		 echo "[ERROR] Mysql did not start correctly ($host : $port)" | tee -a $LOGFILE
		 exit 1
	else
		 echo "[OK] Mysql running correctly" | tee -a $LOGFILE
	fi
  else
      get_sub_test_txt 
      exit;
fi

#=========================
# Run Tests 
#=========================
run_tests(){
 label="$1"
 commandtxt="$2"
 max_threads=0
 
	echo "*****************************************" | tee -a  "${LOGFILE}";
	echo "SUBTEST: $label" | tee -a "${LOGFILE}";
	echo "BLOCK: [START] $label Test $test $testname  (filter: ${filter_subtest}) $(date +'%Y-%m-%d_%H_%M_%S') " | tee -a "${LOGFILE}";
	echo "META: testIdentifyer=${test};dimension=${sysbench_test_dimension};actionType=${type};runNumber=${run};execCommand=$command;subtest=${label};execDate=$(date +'%Y-%m-%d_%H_%M_%S');engine=${engine}" | tee -a "${LOGFILE}";
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
	
	if [ "$command" == "warmup" ] || [ "$command" == "cleanup" ]; then
        THREADS=$sysbench_tables
	fi
	
	if [ "$havePMM" = "true" ]; then
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
	
	for threads in $THREADS;do
	  if [ $max_threads -gt 0 ] && [ $threads -gt $max_threads ]; then
		    echo "max_threads hit we are skipping threads: $threads" | tee -a "${LOGFILE}" 
		   continue; 
	   else 
			echo "======================================"  | tee -a  "${LOGFILE}"
			echo "THREADS=$threads" | tee -a  "${LOGFILE}"
			echo "RUNNING Test $test $testname $label (filter: ${filter_subtest}) Thread=$threads [START] $(print_date_time) " | tee -a "${LOGFILE}"
			echo "======================================" | tee -a  "${LOGFILE}"
		   if [ "$dryrun" == "true" ]; then
			  echo "Command: ${commandtxt} --time=$TIME  --threads=${THREADS} $command "
			else
				if [ "$command" == "warmup" ] || [ "$command" == "cleanup" ]; then
					 echo "Executing: ${commandtxt} --threads=${threads} --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} $command " | tee -a "${LOGFILE}"
					 ${commandtxt} --threads=${threads} --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} $command  | tee -a "${LOGFILE}"
				else
					 echo "Executing: ${commandtxt}  --time=$TIME  --threads=${threads} --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} $command " | tee -a "${LOGFILE}"
					 ${commandtxt}  --time=$TIME  --threads=${threads} --mysql-ignore-errors=${error_ignore} ${rate} --reconnect=${reconnect} $command  | tee -a "${LOGFILE}"
			    fi
		   fi   
			echo "======================================" | tee -a "${LOGFILE}"
			echo "RUNNING Test $test $testname $label (filter: ${filter_subtest}) Thread=$threads [END] $(print_date_time) " |tee -a "${LOGFILE}"
			echo "======================================" 
	  fi
	done;

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
if [ "$subtest" == "all" ] && [ ! "$testname" == "all" ]; then
     get_sub_test
    # echo "$subtest_execute"

 elif [ ! "$subtest" == "all" ] && [ "$testname" == "all" ]; then
      echo "You cannot run all the different test types at once (ingest|sysbench|tpcc)"
	  exit;
 elif [ ! "$subtest" == "all" ] && [ ! "$testname" == "all" ]; then
     get_sub_test
     # echo "$subtest_execute"
 else
      	echo "You need to pick either a set of subtests or a testname  (ingest|sysbench|tpcc)"  
      	exit; 
fi

if [ ! "$dryrun" == "true" ]; then 
	if [ $testname == "sysbench" ] || [ $testname == "ingest" ] ; then
		cd $SYSBENCH_LUA
	  elif [ $testname == "ingest" ]; then   
		cd $SYSBENCH_LUA
	  elif [ $testname == "tpcc" ]; then 
		cd $TPCC_LUA  
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

#push end time info
echo "METACOLLECTION: enddate=$(date +'%Y-%m-%d_%H_%M_%S')" | tee -a $LOGFILE
#reset path
cd $LOCAL_PATH
exit



