#!/bin/bash
testidentifyer=${1:-"PS8035"}
bin_path="/opt/tools/benchmarktools/software"
for type in run_tpcc_RepeatableRead run_tpcc_ReadCommitted ; do
	echo "Running type: ${type}"
	for run in 1 ; do
		echo "Running round: ${run}"
		echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname tpcc"

		bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 200 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname tpcc
	done;
done;
