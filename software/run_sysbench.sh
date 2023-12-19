#!/bin/bash
testidentifyer=${$1:-"PS8035"}
 
bin_path="/opt/tools/benchmarktools/software"
    for dimension in small large; do
        echo "Running dimension: ${dimension}"
        for type in select write select; do
            echo "Running type: ${type}"
            for run in 1 ; do
                echo "Running round: ${run}"
                echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname windmills_${dimension}"

                bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname windmills_${dimension}
            done;
        done;
    done;
