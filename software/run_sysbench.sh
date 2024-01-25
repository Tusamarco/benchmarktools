#!/bin/bash
testidentifyer=${1:-"PS8035"}
HOST=${2:-"127.0.0.1"}
PORT=${3:-"3306"}
PMMURL=${4:-"http://admin:admin@127.0.0.1"}
HAVEPMM=${5:-"false"}
PMMNODENAME=${6:-"bench"}
havePMM=""

if [ "$HAVEPMM" = "true" ]; then
	havePMM="--havePMM"
fi

bin_path="/opt/tools/benchmarktools/software"
    for dimension in small large; do
        echo "Running dimension: ${dimension}"
        echo "Warmup phase"
        echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest \"warmup_run_select_scan\"  --THREADS \"1\" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME"

        bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest \"warmup_run_select_scan\"  --THREADS "1" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME
        
        for type in select write select; do
            echo "Running type: ${type}"
            for run in 1 ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST} --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME"

                bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension ${dimension}  --host ${HOST}  --port ${PORT} --schemaname windmills_${dimension} $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME
            done;
        done;
    done;
