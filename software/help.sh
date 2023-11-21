help(){

cat << EOF

Command line: Usage: $0 --command=run --test <test Identifier> --testname <sysbench|tpcc|ingest> --subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list --dryrun]

script: $0 

Parameters:
        --command: The action to perform cleanup|prepare|run
        --dryrun: Printout the commands that will run without executing them
        --test: The ID for the current test set IE PS8034
        --testname: The testname you want to run [ingest|sysbench|tpcc]
        --subtest: The specific subtest you want to run OR all (see output of --subtest_list)
        --filter_subtest: Text to filter the subtest list. IE: "select" for sysbench will only return the select tests
        --schemaname: Schema name 
        --engine: Engine to use default Innodb [innodb|myrocks]
        --tablename: Table name for sysbench and Ingest 
        --host: MySQL host
        --port: MySQL poer
        --debug: extended output to standard out
        --subtest_list: List of all sub test 
        --help: this help                        

Sub Tests
	To visualize the subtests lists:
	$0 --subtest_list --testname all --command all
	Will show all sub tests for all commands and type of tests
    
   	$0 --subtest_list --testname ingest --command run
   	Will show only the subtests for Ingest and for the run command.
   		 

EOF
exit
}