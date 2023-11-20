fill_ingest_map(){
  ingest_tests["clean_prepare_1_table_no_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=0 --create_compound=0  --all_in_one=1 --threads=1"
  ingest_tests["run_1_table_no_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=1 --rate=100 --time=${time}  --threads=${threads}"
  ingest_tests["clean_prepare_10_tables_no_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=0 --create_compound=0  --all_in_one=0 --threads=1"
  ingest_tests["run_10_tables_no_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable   --all_in_one=0 --rate=100 --time=${time}  --threads=${threads} "
  ingest_tests["clean_prepare_1_table_with_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=1 --create_compound=1 --all_in_one=1 --threads=1"
  ingest_tests["run_1_table_with_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=1 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=1 --rate=100 --time=${time}  --threads=${threads}"
  ingest_tests["clean_prepare_10_table_with_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --create_secondary=1 --create_compound=1  --all_in_one=0 --threads=10"
  ingest_tests["run_10_table_with_PK"]="sysbench /opt/tools/sysbench/src/lua/windmills/oltp_write.lua  --mysql-host=${host} --mysql-port=${port} --mysql-user=${user} --mysql-password=${password} --mysql-db=${dbname} --db-driver=mysql --tables=10 --skip_trx=on --report-interval=1 --mysql-ignore-errors=none --histogram --table_name=${table_name}  --stats_format=csv --db-ps-mode=disable --all_in_one=0 --rate=100 --time=${time}  --threads=${threads}"
}
ads}"
}
