print_subtest_key(){
sorted="$1"
subtest_execute=""
	if [ "$command" == "cleanup" ] || [ "$command" == "prepare" ] || [ "$command" == "all" ]; then
		for key in ${sorted}; do
			if [[ "$key" =~ "clean" ]];then
			    if [[ ! "$filter_subtest" == "none" ]];then
					if [[ "$key" =~ "$filter_subtest" ]];then
						subtest_execute+="$key "
					fi
					else
					 subtest_execute+="$key "	
				fi
			fi
		done
	fi
	if [ "$command" == "run" ] || [ "$command" == "all" ]; then	
		for key in ${sorted}; do
			if ! [[ "$key" =~ "clean" ]];then
			    if [[ ! "$filter_subtest" == "none" ]];then
					if [[ "$key" =~ "$filter_subtest" ]];then
						subtest_execute+="$key "
					fi
					else
					 subtest_execute+="$key "	
				fi
			fi
		done
	fi	
}

print_subtest_key_txt(){
sorted="$1"

	if [ "$command" == "cleanup" ] || [ "$command" == "prepare" ] || [ "$command" == "all" ]; then
		echo "-- cleanup prepare --"
		for key in ${sorted}; do
			if [[ "$key" =~ "clean" ]];then
				echo "   $key "
			fi
		done
	fi
	if [ "$command" == "run" ] || [ "$command" == "all" ]; then	
		echo "-- run --"
		for key in ${sorted}; do
			if ! [[ "$key" =~ "clean" ]];then
				echo "   $key "
			fi
		done
	fi	
}


get_sub_test_txt(){
	if [ "$debug" == true ]; then
		echo $command
		echo $testname
	fi

    if [ "$testname" == "ingest" ] || [ "$testname" == "all" ]; then 
		echo "-- Ingest --"
		echo "SubTests:"
		sorted=`echo ${!ingest_tests[@]}|tr ' ' '\012' | sort| tr '\012' ' '`
		print_subtest_key_txt "$sorted"
	fi	

    if [ "$testname" == "sysbench" ] || [ "$testname" == "all" ]; then 
		echo "-- Sysbench --"
		echo "SubTests:"
		sorted=`echo ${!sysbench_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key_txt "$sorted"

    fi 

    if [ "$testname" == "tpcc" ] || [ "$testname" == "all" ]; then 
		echo "-- Tpcc --"
		echo "SubTests:"
		sorted=`echo ${!tpcc_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key_txt "$sorted"
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

get_sub_test(){
	if [ "$debug" == true ]; then
		echo $command
		echo $testname
	fi

    if [ "$testname" == "ingest" ] || [ "$testname" == "all" ]; then 
		sorted=`echo ${!ingest_tests[@]}|tr ' ' '\012' | sort| tr '\012' ' '`
		print_subtest_key "$sorted"
	fi	

    if [ "$testname" == "sysbench" ] || [ "$testname" == "all" ]; then 
		sorted=`echo ${!sysbench_tests[@]}|tr ' ' '\012' | sort | tr '\012' ' '`
		print_subtest_key "$sorted"

    fi 

    if [ "$testname" == "tpcc" ] || [ "$testname" == "all" ]; then 
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