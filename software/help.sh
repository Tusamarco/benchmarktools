helptext(){

cat << EOF

Command line: Usage: $0 --command=run --test <test Identifier> --testname <sysbench|tpcc|ingest> --subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list --dryrun]

script: $0 

Parameters:
        --command: The action to perform cleanup|prepare|run
        --debug: extended output to standard out
        --dryrun: Printout the commands that will run without executing them
        --engine: Engine to use default Innodb [innodb|myrocks]
        --filter_subtest: Text to filter the subtest list. IE: "select" for sysbench will only return the select tests
        --help: this help                        
        --host: MySQL host
        --port: MySQL poer
        --schemaname: Schema name 
        --subtest_list: List of all sub test to see all (--subtest_list --command all --testname all)
        --subtest: The specific subtest you want to run OR all (see output of --subtest_list)
        --sysbench_test_dimension: we have 2 standard dimension small and large. Default is small:
								SYSNBENCH_ROWS_LARGE=30000000
								SYSNBENCH_ROWS_SMALL=10000000
								SYSNBENCH_TABLES_LARGE=5
								SYSNBENCH_TABLES_SMALL=20
			So small has smaller tables but more of them, large is more about few tables and more rows.
        --tablename: Table name for sysbench and Ingest 
        --test: The ID for the current test set IE PS8034
        --testname: The testname you want to run [ingest|sysbench|tpcc]
        --THREADS: the set of threads to use to run the tests use double quote as "2 4 8 16"
        --TIME: the execution time for the tests in seconds IE 600

Sub Tests
	To visualize the subtests lists:
	$0 --subtest_list --testname all --command all
	Will show all sub tests for all commands and type of tests
    
   	$0 --subtest_list --testname ingest --command run
   	Will show only the subtests for Ingest and for the run command.
   		 

EOF
exit
}