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
        --schemaname: Schema name 
        --engine: Engine to use default Innodb [innodb|myrocks]
        --tablename: Table name for sysbench and Ingest 
        --host: MySQL host
        --port: MySQL poer
        --debug: extended output to standard out
        --subtest_list: List of all sub test 
        --help: this help                        

Sub Tests
	all - runs all the RUN test, no preparation or cleanup
    IE testname=sysbench subtest=all will run all the sysbench tests

-- Ingest --
SubTests:
   clean_prepare_10_tables_no_PK 
   clean_prepare_10_table_with_PK 
   clean_prepare_1_table_no_PK 
   clean_prepare_1_table_with_PK 
   run_10_tables_no_PK 
   run_10_table_with_PK 
   run_1_table_no_PK 
   run_1_table_with_PK 
-- Sysbench --
SubTests:
   clean_prepare_large 
   clean_prepare_small 
   select_run_inlist 
   select_run_inlist_hotspot 
   select_run_point_select 
   select_run_range_all 
   select_run_range_distinct 
   select_run_range_order 
   select_run_range_simple 
   select_run_range_sum 
   select_run_select_scan 
   write_run_inlist_update 
   write_run_inlist_update_hotspot 
   write_run_insert_delete_multi 
   write_run_insert_delete_single 
   write_run_replace_delete_multi 
   write_run_replace_delete_single 
   write_run_rw_with_range_100 
   write_run_rw_with_range_1000 
   write_run_update_no_index_multi 
   write_run_update_no_index_multi_special 
   write_run_update_no_index_single 
   write_run_update_with_index_multi 
   write_run_update_with_index_multi_special 
   write_run_update_with_index_single 
   write_run_write_all_no_trx 
   write_run_write_all_with_trx 
   write_run_write_all_with_trx_special 
-- Tpcc --
SubTests:
   cleanup_prepare_tpcc 
   run_tpcc_ReadCommitted 
   run_tpcc_RepeatableRead 

EOF
exit
}