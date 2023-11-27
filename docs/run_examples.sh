test plan for sysbench

execute two runs of each test:

1)SMALL && LARGE
    1) SELECT only x 2 runs:
     bash run_bench_tests.sh --test PS8034_small  --testname sysbench --command run  --filter_subtest select  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 600 --sysbench_test_dimension small  --host 10.0.68.39 --port 3307 --schemaname windmills_small
    
    2)Write only x 2 runs:
    bash run_bench_tests.sh --test PS8034_small  --testname sysbench --command run  --filter_subtest write  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 600 --sysbench_test_dimension small  --host 10.0.68.39 --port 3307 --schemaname windmills_small
    
    3) SELECT only x 2 runs:
    bash run_bench_tests.sh --test PS8034_small  --testname sysbench --command run  --filter_subtest select  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 600 --sysbench_test_dimension small  --host 10.0.68.39 --port 3307 --schemaname windmills_small
    
    will be as command 
    
    for dimension in small large; do
        for type in select write;do
            for run in 1 2;do 
                bash run_bench_tests.sh --test PS8034_${dimension}_${type}_${run}  --testname sysbench --command run  --filter_subtest ${type}  --THREADS "1 2 4 8 16 32 64 128 256 512 1024" --TIME 600 --sysbench_test_dimension ${dimension}  --host 10.0.68.39 --port 3307 --schemaname windmills_${dimension}
            done;       
        done;
    done;