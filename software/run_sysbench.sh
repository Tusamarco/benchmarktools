#!/bin/bash
testidentifyer="PS8035"
HOST="127.0.0.1"
PORT="3306"
TIME="600"
PMMURL="http://admin:admin@127.0.0.1"
HAVEPMM="false"
HAVEPERF="false"
PMMNODENAME="bench"
PMMSERVICENAME=""
LOOPS=1
THREADS="1 2 4 8 16 32 64 128 256 512 1024"
DRYRUN="false"
TESTS_TYPES="select write select"
NO_PRELOAD="false"
SYSBENCH_TEST_DIMENSION="small large"
TESTNAME="sysbench"
SCHEMANAME=""
RATE=""
EVENTS="0"
TABLENAME=""
FILTER_SUBTEST="none"
EXCLUDE_SUBTEST="none"
ERROR_IGNORE="none"
command="run"

bin_path= SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ ! -d "$bin_path" ]]; then 
    bin_path="/opt/tools/benchmarktools/software"
fi

echo "INFO: Using bin path: $bin_path"

helptext(){
cat << EOF

Command line: Usage: $0  --testidentifyer MY8042_iron_ssd2 --HOST 10.0.0.23 --PORT 3307 --TIME 120 --LOOPS 3 --HAVEPMM --PMMURL "http://admin:admin@x.y.z.a/" --PMMNODENAME bench-2 --HAVEPERF
./run_sysbench.sh --testidentifyer mysql-8.4.7 --HOST 127.0.0.1 --PORT 3307 --TIME 200 --LOOPS 1 --HAVEPMM --PMMURL "http://<user>:<pw>@ip" --PMMNODENAME blade3 --SYSBENCH_TEST_DIMENSION "small"

To run joins tests:
./run_sysbench.sh --testidentifyer mysql-8.4.7 --HOST 127.0.0.1 --PORT 3306 --TIME 200 --LOOPS 1 --HAVEPMM --PMMURL "http://<user>:<pw>@ip" --PMMNODENAME blade3 --SYSBENCH_TEST_DIMENSION  "joins" --TESTNAME "joins" --TESTS_TYPES "select" --FILTER_SUBTEST "simple_inner_pk" --EVENTS 1000 --SCHEMANAME "joins"


More complex run:
./run_sysbench.sh --testidentifyer mariadb-11-8-5-joins-test --HOST 127.0.0.1 --PORT 3307 --TIME 0 --EVENTS 1 --LOOPS 1 --HAVEPMM --PMMURL "http://<user>:<pw>@<ip>" --PMMNODENAME mypmm --TESTNAME joins --COMMAND run --NOPRELOAD --THREADS "1 2 4 8 16"  --ERROR_IGNORE "all" --SYSBENCH_TEST_DIMENSION small --TESTS_TYPES selects


script: $0 

Parameters:
Connection Settings:
  --HOST <address>              The database hostname or IP address.
  --PORT <number>               The database port number.

Test Configuration:
  --testidentifyer <string>     A unique string ID to tag this execution (e.g., for history).
  --TESTNAME <string>           Name of the test suite/scenario being executed.
  --SCHEMANAME <name>           Database schema (database) name to use. 
  --SYSBENCH_TEST_DIMENSION <N> Defines data scale (e.g., number of rows/tables).
  --THREADS <number>            Number of concurrent threads (workers).
  --TIME <seconds>              Duration for the test to run.
  --RATE <number>               Limit the request rate (transactions per second) it will disable TIME.
  --EVENTS <number>             Number of events to run (transactions). It will disable TIME.
  --LOOPS <number>              Number of times to repeat the test cycle.
  --COMMAND <action>            The action to perform: prepare, run, cleanup.

Execution Control:
  --TESTS_TYPES <actions>       Stages to perform, list of action space separated (e.g. "select write select"; "select"; "read/write").
  --FILTER_SUBTEST <pattern>    Filter to run only specific sub-tests (e.g., specific join types).
  --EXCLUDE_SUBTEST <pattern>   Exclude specific sub-tests matching the pattern. (e.g., update).
  --NOPRELOAD                   Skip data preparation/loading (assumes data exists).
  --DRYRUN                      Simulate execution (print commands without running).

Monitoring & Profiling:
  --HAVEPMM                     Enable Percona Monitoring and Management (PMM) markers.
  --PMMURL <url>                The PMM server URL.
  --PMMNODENAME <name>          Node Name for PMM registration.
  --PMMSERVICENAME <name>       Service Name for PMM registration.
  --HAVEPERF                    Enable Linux 'perf' tool profiling.



EOF
exit
}


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        "") 
            shift 
            ;;
        --testidentifyer)
            testidentifyer="$2"
            shift 2
            ;;
        --HOST)
            HOST="$2"
            shift 2
            ;;
        --PORT)
            PORT="$2"
            shift 2
            ;;
        --PMMURL)
            PMMURL="$2"
            shift 2
            ;;
        --HAVEPMM)
            HAVEPMM="true"
            shift 1
            ;;    
        --HAVEPERF)
            HAVEPERF="true"
            shift 1
            ;;       
        --NOPRELOAD)
            NO_PRELOAD="true"
            shift 1
            ;;                             
        --DRYRUN)
            DRYRUN="true"
            shift 1
            ;;    
        --PMMNODENAME)
            PMMNODENAME="$2"
            shift 2
            ;;
       --PMMSERVICENAME)
            PMMSERVICENAME="$2"
            shift 2
            ;;
        --TIME)
            TIME="$2"
            shift 2
            ;;
        --RATE)
            RATE="--rate $2"
            shift 2
            ;;
        --EVENTS)
            EVENTS="$2"
            shift 2
            ;;  
        --LOOPS)
            LOOPS="$2"
            shift 2
            ;;
        --TESTS_TYPES)
            TESTS_TYPES="$2"
            shift 2
            ;;
        --SYSBENCH_TEST_DIMENSION)
            SYSBENCH_TEST_DIMENSION="$2"
            shift 2
            ;;
        --FILTER_SUBTEST)
            FILTER_SUBTEST=$2
            shift 2
            ;;
        --EXCLUDE_SUBTEST)
            EXCLUDE_SUBTEST=$2
            shift 2
            ;;
        --TESTNAME)
            TESTNAME="$2"
            shift 2
            ;;            
        --THREADS)
            THREADS="$2"
            shift 2
            ;;
        --COMMAND)
            command="$2"
            shift 2
            ;;
        --ERROR_IGNORE)
            ERROR_IGNORE="$2"
            shift 2
            ;;
        --SCHEMANAME)
            SCHEMANAME="$2"
            shift 2
            ;;  	
        *)
            echo "Unknown argument: $1"
			helptext
            ;;
    esac
done;

havePMM=""
dryRun=""
if [ "$TESTNAME" == "joins" ] ; then
    TESTS_TYPES="joins-select"
fi

echo "Actions I am going to run: $TESTS_TYPES"

if [ "$HAVEPMM" == "true" ]; then
	havePMM="--havePMM"
	if [ ! "$PMMSERVICENAME" == "" ]; then
	   PMMSERVICENAME="--pmm_service_name $PMMSERVICENAME"  
	fi
fi
if [ "$DRYRUN" == "true" ]; then
     dryRun="--dryrun"
fi

if [ "$HAVEPERF" == "true" ]; then
	 havePerf="--haveperf"
fi

if [ "$FILTER_SUBTEST" == "none" ]; then
	 FILTER_SUBTEST=""
else
     FILTER_SUBTEST="--filter_subtest ${FILTER_SUBTEST}"
fi

if [ "$EXCLUDE_SUBTEST" == "none" ]; then
	 EXCLUDE_SUBTEST=""
else
     EXCLUDE_SUBTEST="--exclude_subtest ${EXCLUDE_SUBTEST}"
fi

if [ "$SCHEMANAME" == "" ]; then
    if [ "$TESTNAME" == "joins" ] ; then
        SCHEMANAME="joins"
        SYSBENCH_TEST_DIMENSION="small"
    elif [ "$TESTNAME" == "tpcc" ] ; then
        SCHEMANAME="tpcc"
        SYSBENCH_TEST_DIMENSION="tpcc"
    else
        SCHEMANAME=""
    fi
fi

if [ "$TESTNAME" == "joins" ] ; then
    TABLENAME="--tablename main"
fi

if [ ! "$EVENTS" == "0" ];then
   EVENTS="--events ${EVENTS}" 
   TIME=0
#    echo "NOTE: Events is active events=${EVENTS}, TIME will be disabled TIME=${TIME}" 
 else
    EVENTS=""
#     
fi

for dimension in $SYSBENCH_TEST_DIMENSION; do
    echo "Running dimension: ${dimension}"
    if [ "$TESTNAME" == "sysbench" ] && [ "$SCHEMANAME" == "" ]; then
        SCHEMANAME="windmills_${dimension}"
    fi
    
    if [ "$NO_PRELOAD" == "false" ] && [ "$command" == "run" ]; then
        echo "Warmup phase"
        echo "RUNNING: $bin_path/run_bench_tests.sh ${dryRun}  --test ${testidentifyer} --type warmup --run 1  --testname ${TESTNAME} --command warmup  --filter_subtest \"warmup\"  --threads \"1\" --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} ${TABLENAME} --schemaname ${SCHEMANAME} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME" 

        bash $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type "warmup" --run 1 --testname ${TESTNAME} --command warmup  --filter_subtest warmup  --threads "1" --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} ${TABLENAME} --schemaname ${SCHEMANAME} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME 
    fi
    
    for type in $TESTS_TYPES; do
        echo "Running type: ${type}"
        for loop in `seq 1 $LOOPS` ; do
            echo "Running round: ${run}"
            echo "RUNNING: $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type ${type} --run ${loop}  --testname ${TESTNAME} --command ${command} ${EXCLUDE_SUBTEST} ${FILTER_SUBTEST} --threads \"${THREADS}\" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} ${TABLENAME} --error_ignore ${ERROR_IGNORE} --schemaname ${SCHEMANAME} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf} ${RATE} ${EVENTS}"

            bash $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type ${type} --run ${loop} --testname ${TESTNAME} --command ${command} ${EXCLUDE_SUBTEST} ${FILTER_SUBTEST} --threads "${THREADS}" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} ${TABLENAME} --error_ignore ${ERROR_IGNORE} --schemaname ${SCHEMANAME} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf} ${RATE} ${EVENTS}
        done;
    done;
done;
