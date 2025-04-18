#!/bin/bash
testidentifyer="PS8036"
HOST="127.0.0.1"
PORT="3306"
TIME="200"
PMMURL="http://admin:admin@127.0.0.1"
HAVEPMM="false"
HAVEPERF="false"
DRYRUN="false"
PMMNODENAME="bench"
PMMSERVICENAME=""
LOOPS=1
filter_subtest=""
#THREADS="1"
THREADS="1 2 4 8 16 32 64 128 256 512 1024"
TYPE="write"
#TYPE="select write select"
SYSBENCH_TEST_DIMENSION="small large"

bin_path="/opt/tools/benchmarktools/software"
perf_output_path="/opt/results"

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
--filter_subtest "write_run_rw_heavy_trx"
--THREADS "1 2 4 8 16 32 64 128 256 512 1024 2048"

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
        --THREADS)
            THREADS="$2"
            shift 2
            ;;
        --SYSBENCH_TEST_DIMENSION)
            SYSBENCH_TEST_DIMENSION="$2"
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
            ;;
    esac
done;

havePMM=""
havePerf=""
dryrun=""

if [ "$HAVEPMM" = "true" ]; then
	havePMM="--havePMM"
	if [ ! "$PMMSERVICENAME" == "" ]; then
	   PMMSERVICENAME="--pmm_service_name $PMMSERVICENAME"  
	fi
fi



    for dimension in $SYSBENCH_TEST_DIMENSION; do
		if [ "$HAVEPERF" = "true" ]; then
             havePerf="--haveperf"
        fi
		if [ "$DRYRUN" = "true" ]; then
             dryrun="--dryrun"
        fi
    
    
        for type in ${TYPE};do
			echo "Running dimension: ${dimension}"
	#        echo "Warmup phase"
	#        echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer} --type warmup --run 1  --testname sysbench --command warmup  --filter_subtest \"warmup_run_select_scan\"  --THREADS \"1\" --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"
	
	#        bash $bin_path/run_bench_tests.sh --test ${testidentifyer} --type "warmup" --run 1 --testname sysbench --command warmup  --filter_subtest warmup_run_select_scan  --THREADS "1" --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
			
			echo "Running filter_subtest: ${filter_subtest}"
			for loop in `seq 1 $LOOPS` ; do
				echo "Running round: ${run}"
				echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer} --type ${type} --run ${loop}  --testname sysbench --command run  --filter_subtest ${filter_subtest}  --threads \"${THREADS}\" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf} ${dryrun}" 
	
				bash $bin_path/run_bench_tests.sh --test ${testidentifyer} --type ${type} --run ${loop} --testname sysbench --command run  --filter_subtest ${filter_subtest}  --threads "${THREADS}" --time $TIME --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME ${havePerf} ${dryrun}
			done;
		done;	
		
		
    done;
