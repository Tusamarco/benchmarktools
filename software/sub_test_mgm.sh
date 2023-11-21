get_sub_test(){
	if [ "$debug" == true ]; then
		echo $command
		echo $testname
	fi

    if [ "$testname" == "ingest" ] || [ "$testname" == "all" ]; then 
		echo "-- Ingest --"
		echo "SubTests:"
		sorted=`echo ${!ingest_tests[@]}|tr ' ' '\012' | sort| tr '\012' ' '`
		print_subtest_key "$sorted"
	fi	

    if [ "$testname" == "sysbench" ] || [ "$testname" == "all" ]; then 
		echo "-- Sysbench --"
		echo "SubTests:"
		sorted=`echo ${!sysbench_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key "$sorted"

    fi 

    if [ "$testname" == "tpcc" ] || [ "$testname" == "all" ]; then 
		echo "-- Tpcc --"
		echo "SubTests:"
		sorted=`echo ${!tpcc_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key "$sorted"
    fi

if [ "$debug" == true ]; then 
    echo "Full map value below (with commands)"
    echo "=========================================="
    for key in "${!ingest_tests[@]}"; do
        echo "Key: $key Value: ${ingest_tests[$key]}"
    done


    for key in "${!sysbench_tests[@]}"; do
        echo "Key: $key Value: ${sysbench_tests[$key]}"
    done

    for key in "${!tpcc_tests[@]}"; do
        echo "Key: $key Value: ${tpcc_tests[$key]}"
    done
    echo "=========================================="
fi

}