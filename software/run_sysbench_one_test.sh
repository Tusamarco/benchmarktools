#!/bin/bash
testidentifyer="PS8035"
HOST="127.0.0.1"
PORT="3306"
TIME="600"
PMMURL="http://admin:admin@127.0.0.1"
HAVEPMM="false"
PMMNODENAME="bench"
PMMSERVICENAME=""
LOOPS=1
filter_subtest=""


# testidentifyer=${1:-"PS8035"}
# HOST=${2:-"127.0.0.1"}
# PORT=${3:-"3306"}
# PMMURL=${4:-"http://admin:admin@127.0.0.1"}
# HAVEPMM=${5:-"false"}
# PMMNODENAME=${6:-"bench"}
# PMMSERVICENAME=${7:-""}


helptext(){

cat << EOF

Command line: Usage: $0  --testidentifyer MY8042_iron_ssd2 --HOST 10.0.0.23 --PORT 3307 --TIME 120 --LOOPS 3 --HAVEPMM --PMMURL "http://admin:admin@x.y.z.a/" --PMMNODENAME bench-2

script: $0 

Parameters:
--testidentifyer "PS8035"
--HOST "127.0.0.1"
--PORT "3306"
--TIME "600"
--PMMURL "http://admin:admin@127.0.0.1"
--HAVEPMM
--PMMNODENAME "bench"
--PMMSERVICENAME "bench-mysql-service"   
--LOOPS 1		 

EOF
exit
}


#Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
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
        --LOOPS)
            LOOPS="$2"
            shift 2
            ;;
        --filter_subtest)
            filter_subtest=$2
            shift 2
            ;;
        *)
            echo "Unknown argument: $1"
			helptext
            exit 1
            ;;
    esac
done;

havePMM=""

if [ "$HAVEPMM" = "true" ]; then
	havePMM="--havePMM"
	if [ ! "$PMMSERVICENAME" == "" ]; then
	   PMMSERVICENAME="--pmm_service_name $PMMSERVICENAME"  
	fi
fi

PREFIX="PS"
if [ "$PORT" = "3308" ]; then
	PREFIX="MY"
fi


bin_path="/opt/tools/benchmarktools/software"
    for dimension in small; do
        echo "Running dimension: ${dimension}"
        echo "Warmup phase"
        echo "RUNNING: $bin_path/run_bench_tests.sh --test ${PREFIX}_${testidentifyer} --type warmup --run 1  --testname sysbench --command warmup  --filter_subtest \"warmup_run_select_scan\"  --THREADS \"1\" --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"

        bash $bin_path/run_bench_tests.sh --test ${PREFIX}_${testidentifyer} --type "warmup" --run 1 --testname sysbench --command warmup  --filter_subtest warmup_run_select_scan  --THREADS "1" --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
        
        for type in write; do
            echo "Running type: ${type}"
            for loop in `seq 1 $LOOPS` ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh --test ${PREFIX}_${testidentifyer} --type ${type} --run ${loop}  --testname sysbench --command run  --filter_subtest ${filter_subtest}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME $TIME --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"

                bash $bin_path/run_bench_tests.sh --test ${PREFIX}_${testidentifyer} --type ${type} --run ${loop} --testname sysbench --command run  --filter_subtest ${filter_subtest}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME $TIME --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
            done;
        done;
    done;
