#!/bin/bash
testidentifyer=${1:-"PS8035"}
HOST=${2:-"127.0.0.1"}
PORT=${3:-"3306"}
PMMURL=${4:-"http://admin:admin@127.0.0.1"}
HAVEPMM=${5:-"false"}
PMMNODENAME=${6:-"bench"}
PMMSERVICENAME=${7:-""}

havePMM=""

if [ "$HAVEPMM" = "true" ]; then
	havePMM="--havePMM"
	if [ ! "$PMMSERVICENAME" == "" ]; then
	   PMMSERVICENAME="--pmm_service_name $PMMSERVICENAME"  
	fi
fi

bin_path="/opt/tools/benchmarktools/software"
    for dimension in small large; do
        echo "Running dimension: ${dimension}"
        echo "Warmup phase"
        echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer} --type warmup --run 1  --testname sysbench --command warmup  --filter_subtest \"warmup_run_select_scan\"  --THREADS \"1\" --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"

        bash $bin_path/run_bench_tests.sh --test ${testidentifyer} --type "warmup" --run 1 --testname sysbench --command warmup  --filter_subtest warmup_run_select_scan  --THREADS "1" --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
        
        for type in select write select; do
            echo "Running type: ${type}"
            for run in 1 ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer} --type ${type} --run ${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME"

                bash $bin_path/run_bench_tests.sh --test ${testidentifyer} --type ${type} --run ${run} --testname sysbench --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME $PMMSERVICENAME
            done;
        done;
    done;
