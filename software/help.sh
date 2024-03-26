helptext(){

cat << EOF

Command line: Usage: $0 --command=run --test <test Identifier> --testname <sysbench|tpcc|ingest> --filter_subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list --dryrun]

script: $0 

Parameters:
        --command: The action to perform cleanup|prepare|run
        --debug: extended output to standard out
        --dryrun: Printout the commands that will run without executing them
        --engine: Engine to use default Innodb [innodb|myrocks]
        --error_ignore: Set the level for the option --mysql-ignore-errors. Default none
        --filter_subtest: Text to filter the subtest list. IE: "select" for sysbench will only return the select tests
        --help: this help                        
        --host: MySQL host
        --port: MySQL port
        --reconnect: sysbench will reconnect after the indicated number of events. Default 0 - no reconnect
        --schemaname: Schema name 
        --subtest_list: List of all sub test to see all (--subtest_list --command all --testname all)
        --sysbench_test_dimension: we have 2 standard dimension small and large. Default is small:
								SYSNBENCH_ROWS_LARGE=${SYSNBENCH_ROWS_LARGE}
								SYSNBENCH_ROWS_SMALL=${SYSNBENCH_ROWS_SMALL}
								SYSNBENCH_TABLES_LARGE=${SYSNBENCH_TABLES_LARGE}
								SYSNBENCH_TABLES_SMALL=${SYSNBENCH_TABLES_SMALL}
			So small has smaller tables but more of them, large is more about few tables and more rows.
        --tablename: Table name for sysbench and Ingest 
        --test: The ID for the current test set IE PS8034
        --testname: The testname you want to run [ingest|sysbench|tpcc]
        --testrun: Run the tests with  thread and only for 10 seconds, just to check if they may work
        --THREADS: the set of threads to use to run the tests use double quote as "2 4 8 16"
        --TIME: the execution time for the tests in seconds IE 600
  
        --havePmm: If you have PMM and want to add notation about what test and when it is run, you can enable it here
        --pmm_url: To enable PMM automatic notation, you need to pass the information to connect to the PMM server as "http://user:password@ip:port/"
                   It is advisable you create a special user for such operations with limited privileges  
        --pmm_node_name: The node name where you are running the benchmarking. The value of the name is the NODE name as reported in the PMM inventory.
        --pmm_service_name: The service name in case the node name and service name are different. The value of the name is the SERVICE name as reported in the PMM inventory.



Sub Tests
	To visualize the subtests lists:
	$0 --subtest_list --testname all --command all
	Will show all sub tests for all commands and type of tests
    
   	$0 --subtest_list --testname ingest --command run
   	Will show only the subtests for Ingest and for the run command.
   		 

EOF
exit
}