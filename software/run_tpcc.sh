#!/bin/bash
testidentifyer="PS8035"
HOST="127.0.0.1"
PORT="3306"
TIME="600"
PMMURL="http://admin:admin@127.0.0.1"
HAVEPMM="false"
PMMNODENAME="bench"
PMMSERVICENAME=""
LOOPS="1"


# testidentifyer=${1:-"PS8035"}
# HOST=${2:-"127.0.0.1"}
# PORT=${3:-"3306"}
# PMMURL=${4:-"http://admin:admin@127.0.0.1"}
# HAVEPMM=${5:-"false"}
# PMMNODENAME=${6:-"bench"}
# PMMSERVICENAME=${7:-""}


helptext(){

cat << EOF

Command line: Usage: $0 --testidentifyer MY8042_iron_ssd2 --HOST 10.0.0.23 --PORT 3307 --TIME 120 --LOOPS 3 --HAVEPMM --PMMURL "http://admin:admin@x.y.z.a/" --PMMNODENAME

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
        	LOOPS= "$2"    
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

bin_path="/opt/tools/benchmarktools/software"
for type in run_tpcc_RepeatableRead run_tpcc_ReadCommitted ; do
	echo "Running type: ${type}"
        for run in `seq 1 $LOOPS` ; do
		echo "Running round: ${run}"
		echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME $TIME  --host ${HOST} --port $PORT --schemaname tpcc $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"

		bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME $TIME --host ${HOST} --port $PORT --schemaname tpcc $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
	done;
done;
