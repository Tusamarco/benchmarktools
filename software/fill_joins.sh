fill_joins_map(){
    # Admin commands
    join_tests["joins_prepare"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql --table_name=main  --stats_format=csv --tables=${JOINS_MAIN_TABLES} --table_size=${JOINS_ROWS_PER_TABLE} --mysql-ignore-errors=none "

    join_tests["joins_cleanup"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql --table_name=main  --stats_format=csv --tables=${JOINS_MAIN_TABLES} --table_size=${JOINS_ROWS_PER_TABLE} --mysql-ignore-errors=none "

    join_tests["joins_warmup"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql --table_name=main  --stats_format=csv --tables=${JOINS_MAIN_TABLES} --table_size=${JOINS_ROWS_PER_TABLE} --mysql-ignore-errors=none "

    # Inner Joins tests
    join_tests["simple_inner_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_pk=1 "

    join_tests["simple_inner_pk_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_pk_GB=1 "
    
    join_tests["multilevel_inner_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multilevel_inner_pk=1 "

    join_tests["simple_inner_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_index=1 "

    join_tests["simple_inner_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_index=1 "
    
    join_tests["simple_inner_index_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_index_GB=1 "
    
    join_tests["multilevel_inner_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multilevel_inner_index=1 "

    join_tests["simple_inner_forcing_order_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_forcing_order_GB=1 "

    join_tests["multilevel_inner_forcing_order_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multilevel_inner_forcing_order_index=1 "

    join_tests["simple_inner_straight_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_inner_straight_GB=1 "

    join_tests["multilevel_inner_straight_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multilevel_inner_straight_index=1 "

    # Left Joins tests
    join_tests["simple_left_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_pk=1 "

    join_tests["simple_left_pk_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_pk_GB=1 "

    join_tests["multi_left_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_left_pk=1 "

    join_tests["simple_left_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_index=1 "

    join_tests["simple_left_index_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_index_GB=1 "

    join_tests["multi_left_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_left_index=1 "

    join_tests["simple_left_forcing_order_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_forcing_order_GB=1 "

    join_tests["multi_left_forcing_order_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_left_forcing_order_GB=1 "

    join_tests["simple_left_straight"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_straight=1 "

    join_tests["multi_left_straight"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_left_straight=1 "

    join_tests["simple_left_exclude"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_left_exclude=1 "

    # Right Joins tests
    join_tests["simple_right_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_pk=1 "

    join_tests["simple_right_pk_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_pk_GB=1 "

    join_tests["multi_right_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_right_pk=1 "

    join_tests["simple_right_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_index=1 "

    join_tests["simple_right_index_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_index_GB=1 "

    join_tests["multi_right_index"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_right_index=1 "

    join_tests["simple_right_forcing_order_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_forcing_order_GB=1 "

    join_tests["multi_right_forcing_order_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_right_forcing_order_GB=1 "

    join_tests["simple_right_straight_GB"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --simple_right_straight_GB=1 "

    join_tests["multi_right_straight"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --multi_right_straight=1 "

    join_tests["inner_subquery_multi_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --inner_subquery_multi_pk=1 "

    join_tests["left_subquery_multi_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --left_subquery_multi_pk=1 "

    join_tests["right_subquery_multi_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --right_subquery_multi_pk=1 "

    # Semi/anti/conditional Joins tests
    join_tests["semi_join_exists_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --semi_join_exists_pk=1 "

    join_tests["anti_join_not_exists_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --anti_join_not_exists_pk=1 "

    join_tests["anti_join_left_join_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --anti_join_left_join_pk=1 "

    join_tests["conditional_join_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --conditional_join_pk=1 "

    # Update Joins tests
    join_tests["update_multi_right_join_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --update_multi_right_join_pk=1 "

    join_tests["update_multi_left_join_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --update_multi_left_join_pk=1 "

    join_tests["update_multi_inner_join_pk"]="sysbench ${SYSBENCH_LUA}/src/lua/joins/oltp_read_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${USER} --mysql-password=${PW} --mysql-db=${schemaname} --db-driver=mysql  --skip_trx=off --report-interval=1  --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --rand-type=uniform --update_multi_inner_join_pk=1 "

}
