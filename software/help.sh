helptext(){

cat << EOF

Command line: Usage: $0 --command=run --test <test Identifier> --testname <sysbench|tpcc|ingest> --filter_subtest <see command_list> --schemaname <string> --engine <innodb> --tablename <mills> --host <127.0.0.1> --port <3306> [--debug --subtest_list --dryrun]


e.g : /opt/tools/benchmarktools/software/run_bench_tests.sh  --test mariadb-11-8-5-joins-test --type joins-select --run 1  --testname joins --command run --filter_subtest simple_inner_forcing_order_GB --threads "1 2 4 8 16" --time 0 --sysbench_test_dimension small  --host 127.0.0.1 --port 3306 --tablename main --error_ignore none --schemaname joins --havePMM --pmm_url http://user:pw@<ip> --pmm_node_name blade3    --events 20

 /opt/tools/benchmarktools/software/run_bench_tests.sh  --test mariadb-11-8-5-joins-test --type joins-select --run 1  --testname joins --command run --exclude_subtest "update" --threads "1 2 4 8 16" --time 0 --sysbench_test_dimension small  --host 127.0.0.1 --port 3306 --tablename main --error_ignore none --schemaname joins --havePMM --pmm_url http://user:pw@<ip> --pmm_node_name blade3    --events 20

script: $0 

Parameters:

Database Connection:
  --host <address>              Database hostname or IP address.
  --port <number>               Database port number.
  --user <username>             Database user.
  --password <password>         Database password.
  --schemaname <name>           Database schema (database) name to use.

Sysbench Configuration:
  --threads <number>            Number of concurrent threads (workers).
  --time <seconds>              Duration of the test in seconds.
  --rate <number>               Transaction rate limit (0 for unlimited).
  --events <number>             Number of events to run (transactions). It will disable TIME.
  --sysbench_test_dimension: we have 2 standard dimension small and large. Default is small:
								SYSNBENCH_ROWS_LARGE=${SYSNBENCH_ROWS_LARGE}
								SYSNBENCH_ROWS_SMALL=${SYSNBENCH_ROWS_SMALL}
								SYSNBENCH_TABLES_LARGE=${SYSNBENCH_TABLES_LARGE}
								SYSNBENCH_TABLES_SMALL=${SYSNBENCH_TABLES_SMALL}
			        So small has smaller tables but more of them, large is more about few tables and more rows.
  --tablename <name>            Base name for the test tables.
  --engine <name>               Storage engine to use (e.g., InnoDB, MyRocks).
  --reconnect <val>             Reconnect frequency or flag (sysbench specific).
  --error_ignore <val>          Ignore specific database errors (sysbench specific).

Test Control & Logic:
  --command <action>            Action to perform: prepare, run, cleanup.
  --test <script>               The specific sysbench lua script/path to run.
  --testname <string>           Label/Tag for the test suite.
  --type <string>               Test type classification.
  --run <id/string>             Run identifier.
  --filter_subtest <pattern>    Filter to execute only specific sub-tests (e.g., join types).
  --exclude_subtest <pattern>   Exclude specific sub-tests matching the pattern. (e.g., update).
  --joins_active_levels <N>     Depth of join hierarchy to activate.
  --subtest_list                Flag: List available subtests and exit.
  --testrun                     Flag: Execute a test run validation.

Monitoring & Profiling:
  --havePMM                     Enable Percona Monitoring and Management (PMM) markers.
  --pmm_url <url>               PMM Server URL.
  --pmm_node_name <name>        Node name registration for PMM.
  --pmm_service_name            The service name in case the node name and service name are different. The value of the name is the SERVICE name as reported in the PMM inventory.
  --haveperf                    Enable Linux 'perf' tool profiling.

Debug & Utility:
  --dryrun                      Simulate execution (print commands without running).
  --debug                       Enable verbose debug output.
  --help                        Show this help message.


Sub Tests
	To visualize the subtests lists:
	$0 --subtest_list --testname all --command all
	Will show all sub tests for all commands and type of tests
    
   	$0 --subtest_list --testname ingest --command run
   	Will show only the subtests for Ingest and for the run command.
   		 

EOF
exit
}