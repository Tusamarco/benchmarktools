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
for type in run_tpcc_RepeatableRead run_tpcc_ReadCommitted ; do
	echo "Running type: ${type}"
	for run in 1 ; do
		echo "Running round: ${run}"
		echo "RUNNING: $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS \"1 2 4 8 16 32 64 128 256 512 1024\" --TIME 900  --host ${HOST} --port $PORT --schemaname tpcc $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME"

		bash $bin_path/run_bench_tests.sh --test ${testidentifyer}_${type}_${run}  --testname tpcc --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 900 --host 10.0.68.39 --port $PORT --schemaname tpcc $havePMM --pmm_url $PMMURL --pmm_node_name $PMMNODENAME
	done;
done;
