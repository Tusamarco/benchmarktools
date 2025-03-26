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
TESTS_ACTIONS="select write select"
NO_PRELOAD="false"
SYSBENCH_TEST_DIMENSION="small large"

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
--DRYRUN: if enable will print all commands without executing them

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
        --LOOPS)
            LOOPS="$2"
            shift 2
            ;;
        --TESTSACTIONS)
            TESTS_ACTIONS="$2"
            shift 2
            ;;
        --SYSBENCH_TEST_DIMENSION)
            SYSBENCH_TEST_DIMENSION="$2"
            shift 2
            ;;
        --THREADS)
            THREADS="$2"
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
echo "Actions I am going to run: $TESTS_ACTIONS"

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


bin_path="/opt/tools/benchmarktools/software"
    for dimension in $SYSBENCH_TEST_DIMENSION; do
        echo "Running dimension: ${dimension}"
        
        if [ "$NO_PRELOAD" == "false" ]; then
			echo "Warmup phase"
			echo "RUNNING: $bin_path/run_bench_tests.sh ${dryRun}  --test ${testidentifyer} --type warmup --run 1  --testname sysbench --command warmup  --filter_subtest \"warmup_run_select_scan\"  --threads \"1\" --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME" 
	
			bash $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type "warmup" --run 1 --testname sysbench --command warmup  --filter_subtest warmup_run_select_scan  --threads "1" --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
        fi
        
        for type in $TESTS_ACTIONS; do
            echo "Running type: ${type}"
            for loop in `seq 1 $LOOPS` ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type ${type} --run ${loop}  --testname sysbench --command run  --filter_subtest ${type}  --threads \"${THREADS}\" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf}"

                bash $bin_path/run_bench_tests.sh ${dryRun} --test ${testidentifyer} --type ${type} --run ${loop} --testname sysbench --command run  --filter_subtest ${type}  --threads "${THREADS}" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf}
            done;
        done;
    done;
