#!/bin/bash
#for ip in  56 57; do printf '*******************************************************\n IP: 192.168.4.%s\n************************\n' "${ip}"; ./load_dbt3_data.sh 192.168.4.${ip} /datapath schemaname ;done

    host=${1:- "192.168.4.55"}
    data_path=${3:-`pwd`}
    schema=${2:- "dbt3"}
    user="dba"
    dryrun=0;
    dataversion=data2

echo $data_path/$dataversion

    mysql --defaults-file=$data_path/loaddata.cnf -u${user} -h ${host} < $data_path/create_tablesH.sql    
    CHUNK=50;
	export TABLE_DEF_customer="c_custkey,c_name ,c_address ,c_nationkey,c_phone,c_acctbal,c_mktsegment,c_comment "
    export TABLE_DEF_lineitem="l_orderkey,l_partkey,l_suppkey,l_linenumber,l_quantity,l_extendedprice,l_discount,l_tax,l_returnflag,l_linestatus,l_shipDATE,l_commitDATE,l_receiptDATE,l_shipinstruct,l_shipmode,l_comment"
    export TABLE_DEF_nation="n_nationkey,n_name,n_regionkey,n_comment"
    export TABLE_DEF_orders="o_orderkey,o_custkey,o_orderstatus,o_totalprice,o_orderDATE,o_orderpriority,o_clerk,o_shippriority,o_comment"
    export TABLE_DEF_part="p_partkey,p_name ,p_mfgr,p_brand,p_type ,p_size,p_container,p_retailprice,p_comment"
    export TABLE_DEF_partsup="ps_partkey,ps_suppkey,ps_availqty,ps_supplycost,ps_comment"
    export TABLE_DEF_region="r_regionkey,r_name,r_comment"
    export TABLE_DEF_supplier="s_suppkey ,s_name,s_address ,s_nationkey,s_phone,s_acctbal,s_comment"

    START=$(date +'%Y-%m-%d %H:%M:%S')

    echo "Running Dataload DO NOT STOP IT Start ${START}"
    echo "================================================================="
    export TABLES="lineitem orders partsupp supplier part customer nation region"
    for table in $TABLES;do 
	echo "Loading $table";
	attributes=$(eval "echo \$TABLE_DEF_${table}")
        echo $attributes 
	if [ "$table" = "region" ] || [ "$table" = "nation" ]; then
		if [ $dryrun -eq 0  ];	then 
	                mysql --defaults-file=$data_path/loaddata.cnf -u${user}  -h  ${host} -D ${schema}  -e "LOAD DATA LOCAL INFILE '${data_path}/${dataversion}/${table}.tbl' into table ${table} fields terminated by '|' ($attributes)  ;";
		else
			echo "mysql --defaults-file=$data_path/loaddata.cnf -u${user}  -h  ${host} -D ${schema}  -e \"LOAD DATA LOCAL INFILE '${data_path}/${dataversion}/${table}.tbl' into table ${table} fields terminated by '|' ($attributes)  ;\""
		fi
     else  
            for chunk in `seq 1 $CHUNK`;do  
               if [ $dryrun -eq 0  ];  then
	           printf '*%s' "$chunk"
	           mysql --defaults-file=$data_path/loaddata.cnf -u${user}  -h  ${host} -D ${schema}  -e "LOAD DATA LOCAL INFILE '${data_path}/${dataversion}/${table}.tbl.${chunk}' into table ${table} fields terminated by '|' ($attributes)  ;";
		else
	           echo "mysql --defaults-file=$data_path/loaddata.cnf -u${user}  -h 192.168.4.55 -D ${schema}  -e \"LOAD DATA LOCAL INFILE '${data_path}/${dataversion}/${table}.tbl.${chunk}' into table ${table} fields terminated by '|' ($attributes)  ;\"" 
	       fi
	    done;
	    echo ""
        fi
    done;

    for table in $TABLES;do echo "ANALYZE $table";mysql --defaults-file=$data_path/loaddata.cnf -udbt3  -h  ${host} -D ${schema}  -e "ANALYZE TABLE ${table};";done 

#    ALTER TABLE  lineitem  ADD  INDEX `i_l_shipdate`  (`l_shipdate`),ADD  INDEX `i_l_suppkey_partkey`  (l_partkey, l_suppkey), ADD  INDEX `i_l_partkey` (l_partkey),ADD INDEX `i_l_suppkey`  (l_suppkey),ADD INDEX `i_l_receiptdate`  (l_receiptdate,l_commitdate),ADD  INDEX `i_l_orderkey`  (l_orderkey),ADD INDEX `i_l_orderkey_quantity` (l_orderkey, l_quantity),ADD INDEX `i_l_commitdate`  (l_commitdate), ALGORITHM=INPLACE, LOCK=NONE;

    END=$(date +'%Y-%m-%d %H:%M:%S')

    echo "================================================================="
    echo "Process finished:"
    echo "START: ${START}"
    echo "END  : ${END}"

