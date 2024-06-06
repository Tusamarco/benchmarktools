fill_sysbench_map(){
#fill tables
    sysbench_tests["clean_prepare_small"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable "
    sysbench_tests["clean_prepare_large"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql --tables=5 --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable "

#point select    
    sysbench_tests["select_run_point_select"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_point_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform "

#Select Range    
    sysbench_tests["select_run_range_simple"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform  --type_of_range=simple "
    sysbench_tests["select_run_range_sum"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform  --type_of_range=sum "
    sysbench_tests["select_run_range_order"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform  --type_of_range=order "
    sysbench_tests["select_run_range_distinct"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform  --type_of_range=distinct "
    sysbench_tests["select_run_range_all"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_range_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform  --type_of_range=all "

#in list 
    sysbench_tests["select_run_inlist"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inlist_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --random_points=100 --hot_points=false "
    sysbench_tests["select_run_inlist_hotspot"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inlist_select.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --random_points=100 --hot_points=true "

#select scan
    sysbench_tests["select_run_select_scan"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_scan.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable  --events=2 --rand-type=uniform --launcher_threads_override"

#Sysbench Write only tests
    sysbench_tests["write_run_inlist_update"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inlist_update.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --random_points=100 --hot_points=false "
    sysbench_tests["write_run_inlist_update_hotspot"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_inlist_update.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --random_points=100 --hot_points=true "

#update no indexed 
    sysbench_tests["write_run_update_no_index_single"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --non_index_updates=1"
    sysbench_tests["write_run_update_no_index_multi"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --non_index_updates=100"
    sysbench_tests["write_run_update_no_index_multi_special"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_non_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=special --non_index_updates=10"

#update with indexed 
    sysbench_tests["write_run_update_with_index_single"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --index_updates=1"
    sysbench_tests["write_run_update_with_index_multi"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --index_updates=100"
    sysbench_tests["write_run_update_with_index_multi_special"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_update_index.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=special --index_updates=10"

#Insert/deletes
    sysbench_tests["write_run_insert_delete_single"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_delete_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --delete_inserts=1"
    sysbench_tests["write_run_insert_delete_multi"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_delete_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --delete_inserts=100"
    sysbench_tests["write_run_replace_delete_single"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --use_replace --delete_inserts=1"
    sysbench_tests["write_run_replace_delete_multi"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_insert.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --use_replace --delete_inserts=100"
     
#All write operations at once
    sysbench_tests["write_run_write_all_no_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --delete_inserts=1"
    sysbench_tests["write_run_write_all_with_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --delete_inserts=1"
    sysbench_tests["write_run_write_all_with_trx_special"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=special --delete_inserts=1"

#Read and Write with range selects
    sysbench_tests["write_run_rw_with_range_100"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=1 --range_size=100"
    sysbench_tests["write_run_rw_with_range_1000"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=1 --range_size=1000"

#10% Writes 90% Select writes with Reads with and without transactions
   sysbench_tests["write_run_rw_25%_writes_notrx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=180 --range_size=180 --index_updates=20 --non_index_updates=10 --delete_inserts=10"

   sysbench_tests["write_run_rw_25%_writes_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=180 --range_size=180 --index_updates=20 --non_index_updates=10 --delete_inserts=10"


#25% Writes 75% Select writes with Reads with and without transactions
   sysbench_tests["write_run_rw_25%_writes_notrx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=150 --range_size=150 --index_updates=50 --non_index_updates=25 --delete_inserts=25"

   sysbench_tests["write_run_rw_25%_writes_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=150 --range_size=150 --index_updates=50 --non_index_updates=25 --delete_inserts=25"



#50% Writes 50% Select writes with Reads with and without transactions
   sysbench_tests["write_run_rw_50%_writes_notrx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=100 --range_size=100 --index_updates=120 --non_index_updates=40 --delete_inserts=40"

   sysbench_tests["write_run_rw_50%_writes_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=100 --range_size=100 --index_updates=120 --non_index_updates=40 --delete_inserts=40"


#75% Writes 25% Select writes with Reads with and without transactions
   sysbench_tests["write_run_rw_75%_writes_notrx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=50 --range_size=50 --index_updates=160 --non_index_updates=70 --delete_inserts=70"

   sysbench_tests["write_run_rw_75%_writes_trx"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --point_selects=50 --range_size=50 --index_updates=150 --non_index_updates=70 --delete_inserts=70"

#WARMUP action
    sysbench_tests["warmup_run_select_scan"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_scan.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable  --rand-type=uniform --launcher_threads_override"    


#Cleanup action
    sysbench_tests["cleanup_run_select_scan"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_scan.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=on --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable  --rand-type=uniform --launcher_threads_override"        
    
}