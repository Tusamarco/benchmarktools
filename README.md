# BenchmarkTools

BenchmarkTools is a comprehensive toolkit designed to simplify and streamline database benchmarking processes. It includes scripts and tools to set up benchmarking environments, run various database tests, and analyze results efficiently.

## Features

- **Test Automation**:
  - Scripts to automate Sysbench, TPC-C, and ingestion tests.
  - Separate script sets for DBt3 testing.

- **Data Preparation**:
  - Pre-configured setups for various MySQL versions.
  - Instructions for custom configurations including EBS volume preparation.

- **Advanced Logging and Analysis**:
  - Scripts to parse logs and generate statistics.
  - Compatibility with monitoring tools like PMM.
  
- **Highly Configurable**:
  - Support for multiple threads, time duration, and event controls for tests.
  - Customizable database and schema settings.

## Pre-Requisites

1. MySQL or compatible database running on your host or EC2 instance.
2. Benchmarking tools like [Sysbench](https://github.com/Tusamarco/sysbench/tree/percona-testing) and [Sysbench-tpcc](https://github.com/Tusamarco/sysbench-tpcc).
3. Familiarity with the setup instructions as detailed in the `docs/HOW_TO.md`.

## How to Use BenchmarkTools
### Setting Up the Benchmarking Environment
- Use the pre-configured MySQL/PS image or set up a custom database instance.
- Prepare the file system for EBS volume if used:
    ```bash
    fdisk /dev/nvme2n1p1 
    mkfs.ext4 /dev/nvme2n1p1
    mount -o noatime,nodiratime -t ext4 /dev/nvme2np1 /opt/mysql_instances
    ```
### Running Tests
- Use `run_bench_tests.sh` for primary benchmarking. Access its help menu with:
    ```bash
    ./run_bench_tests.sh --help
    ```
- Tests supported:
    - **Sysbench**: "small/large dimension tests."
    - **TPC-C** tests.
    - **Joins** analysis. 



# RUN SYSBENCH script

# Database Benchmark Orchestrator

This script serves as a high-level wrapper and orchestrator for database benchmarking (specifically targeting Sysbench workflows). It automates the process of running complex test scenarios, managing warmup phases, varying thread counts, and integrating with **Percona Monitoring and Management (PMM)** and Linux `perf`.

## 📋 Features

* **Automated Workflow:** Loops through specified test dimensions, test types (e.g., select, write), and iterations.
* **PMM Integration:** Automatically marks start/end points in PMM annotations for easy correlation between tests and metrics.
* **Warmup Handling:** Includes an automatic warmup phase (single thread) before the actual stress tests to prime the buffer pool.
* **Flexible Configuration:** granular control over time, events, rate limiting, and thread counts.
* **Sub-test Filtering:** Ability to include or exclude specific Sysbench sub-tests.

## 🚀 Prerequisites

1. **Target Database:** A running instance of MySQL or MariaDB.
2. **Core Script:** This script expects a file named `run_bench_tests.sh` to exist in the same directory (or in `/opt/tools/benchmarktools/software`).
3. **Dependencies:**
* `sysbench` (installed on the runner machine).
* `curl` (for PMM API calls).



## 🛠 Usage

```bash
./run_sysbench_wrapper.sh [OPTIONS]

```

### Basic Example

```bash
./run_sysbench_wrapper.sh \
  --testidentifyer "mysql-8.4-baseline" \
  --HOST 127.0.0.1 --PORT 3306 \
  --TIME 300 --LOOPS 1 \
  --SYSBENCH_TEST_DIMENSION "small"

```

## ⚙️ Configuration Options

### Connection Settings

| Flag | Description | Default |
| --- | --- | --- |
| `--HOST` | Database hostname or IP address. | `127.0.0.1` |
| `--PORT` | Database port number. | `3306` |

### Test Scope & Metadata

| Flag | Description | Default |
| --- | --- | --- |
| `--testidentifyer` | Unique string ID to tag the execution (used for history/logs). | `PS8035` |
| `--TESTNAME` | Name of the test suite (e.g., `sysbench`, `joins`, `tpcc`). | `sysbench` |
| `--SCHEMANAME` | Database schema name. If empty, auto-generated based on dimension (e.g., `windmills_small`). | *(Auto)* |
| `--SYSBENCH_TEST_DIMENSION` | Data scale definitions (space-separated, e.g., "small large"). | `small large` |
| `--TESTS_TYPES` | List of stages to perform (e.g., "select write"). | `select write select` |
| `--COMMAND` | Action to perform: `prepare`, `run`, `cleanup`. | `run` |

### Runtime & Load

| Flag | Description | Default |
| --- | --- | --- |
| `--THREADS` | Space-separated list of thread counts to iterate through. | `1 2 ... 1024` |
| `--TIME` | Duration of the test in seconds. | `600` |
| `--EVENTS` | Number of transactions to run. **Disables TIME if set.** | `0` |
| `--RATE` | Limit the request rate (TPS). **Disables TIME if set.** | *(Unlimited)* |
| `--LOOPS` | Number of times to repeat the specific test cycle. | `1` |
| `--NOPRELOAD` | Skip the warmup/data loading phase. | `false` |
| `--DRYRUN` | Print the generated commands without executing them. | `false` |

### Filters

| Flag | Description |
| --- | --- |
| `--FILTER_SUBTEST` | Pattern to run only specific sub-tests (e.g., `simple_inner_pk`). |
| `--EXCLUDE_SUBTEST` | Pattern to exclude specific sub-tests (e.g., `update`). |
| `--ERROR_IGNORE` | Ignore specific errors during execution (e.g., `all`). |

### Monitoring & Profiling

| Flag | Description |
| --- | --- |
| `--HAVEPMM` | Enable PMM annotation markers. |
| `--PMMURL` | The PMM server URL (format: `http://user:pass@ip`). |
| `--PMMNODENAME` | The Node Name to register in PMM. |
| `--PMMSERVICENAME` | The Service Name to register in PMM. |
| `--HAVEPERF` | Enable Linux `perf` tool profiling. |

---

## 📖 Execution Logic

When you run the script, it follows this nested logic:

1. **Dimension Loop:** Iterates through `SYSBENCH_TEST_DIMENSION` (e.g., First `small`, then `large`).
2. **Warmup:** Runs a single-threaded warmup (unless `--NOPRELOAD` is set).
3. **Type Loop:** Iterates through `TESTS_TYPES` (e.g., `select`, then `write`).
4. **Loop Counter:** Repeats the test `N` times based on `--LOOPS`.
5. **Thread Iteration:** Within the underlying script, it will execute against the provided `--THREADS` list.

## 💡 Examples

### 1. Standard Sysbench Run with PMM

Runs a standard test against a specific schema size, reporting start/end times to PMM.

```bash
./run_sysbench_wrapper.sh \
  --testidentifyer mysql-8.4.7 \
  --HOST 127.0.0.1 --PORT 3307 \
  --TIME 200 --LOOPS 1 \
  --HAVEPMM --PMMURL "http://admin:admin@192.168.1.50" --PMMNODENAME blade3 \
  --SYSBENCH_TEST_DIMENSION "small"

```

### 2. Join Tests (Custom Schema)

Runs specific join queries against a schema named "joins" for a fixed number of events (1000) rather than a fixed time.

```bash
./run_sysbench_wrapper.sh \
  --testidentifyer mysql-joins-test \
  --HOST 127.0.0.1 --PORT 3306 \
  --TESTNAME "joins" \
  --TESTS_TYPES "select" \
  --FILTER_SUBTEST "simple_inner_pk" \
  --EVENTS 1000 \
  --SCHEMANAME "joins" \
  --SYSBENCH_TEST_DIMENSION "joins"

```

### 3. Complex Read/Write with Filters

A complex scenario skipping the warmup, ignoring errors, and filtering only for write tests.

```bash
./run_sysbench_wrapper.sh \
  --testidentifyer mariadb-rw-test \
  --HOST 127.0.0.1 --PORT 3307 \
  --TIME 60 --LOOPS 1 \
  --HAVEPMM --PMMURL "http://admin:password@10.0.0.5" \
  --PMMNODENAME blade3 \
  --TESTNAME sysbench --COMMAND run \
  --NOPRELOAD \
  --THREADS "1 4 8" \
  --ERROR_IGNORE "all" \
  --FILTER_SUBTEST "%_writes" \
  --TESTS_TYPES "read/write" \
  --SYSBENCH_TEST_DIMENSION "small"

```


# RUN Benchmark script
---

# Benchmark Execution Engine (`run_bench_tests.sh`)

This script is the core execution engine for database performance testing. While it can be orchestrated by a higher-level wrapper, it is designed to be run independently for granular control over specific test scenarios, thread scaling, and profiling.

It handles the execution of Lua-based Sysbench scripts, manages database connections, controls concurrency, and integrates deeply with observability tools.

## 🌟 Key Features

* **Multi-Suite Support:** Native support for Standard Sysbench (OLTP), TPC-C, Custom Join tests, and Ingest scenarios.
* **Automatic Profiling:** Can trigger Linux `perf` to capture system calls and generate **FlameGraphs** automatically upon test completion.
* **PMM Integration:** Sends "Start" and "End" annotations to **Percona Monitoring and Management (PMM)** to correlate benchmark runs with metrics.
* **Safety Mechanisms:** Monitors active MySQL process counts and pauses execution if the database is overloaded/stalled before starting the next thread iteration.
* **Granular Filtering:** precise inclusion (`--filter_subtest`) or exclusion (`--exclude_subtest`) of specific query patterns.

## 🧩 Architecture

## 📋 Prerequisites

1. **Dependencies:**
* `sysbench` (must be installed and in path or configured in script constants).
* `curl` (for PMM API communication).
* `perl` (for FlameGraph generation).
* `perf` (Linux profiling tool, optional but recommended).


2. **Helper Scripts:** The script expects the following files in the same directory:
* `fill_sysbench_map.sh`
* `fill_tpcc_map.sh`
* `fill_joins.sh`
* `fill_ingest_map.sh`
* `help.sh`


3. **Directory Structure:** Default paths assume tools are located in `/opt/tools/` (e.g., `/opt/tools/FlameGraph/`). *Modify the `#constants` section in the script if your paths differ.*

## 🚀 Usage

```bash
./run_bench_tests.sh [OPTIONS]

```

### Argument Reference

#### Database Connection

| Flag | Description | Default |
| --- | --- | --- |
| `--host` | Database IP/Hostname. | `127.0.0.1` |
| `--port` | Database Port. | `3306` |
| `--user` | Database User. | `app_test` |
| `--password` | Database Password. | `test` |
| `--schemaname` | Schema (Database) name. | `windmills_small` |
| `--engine` | Storage engine (e.g., `innodb`, `myrocks`). | `innodb` |

#### Test Definition

| Flag | Description | Default |
| --- | --- | --- |
| `--testname` | Suite to run: `sysbench`, `tpcc`, `joins`, `ingest`. | `sysbench` |
| `--command` | Action: `prepare`, `run`, `cleanup`. | `run` |
| `--type` | Category (e.g., `write`, `select`, `read/write`). | *(Empty)* |
| `--sysbench_test_dimension` | Scale definition: `small` (10M rows) or `large` (30M rows). | `small` |
| `--filter_subtest` | Regex to **include** only specific sub-tests. | `none` |
| `--exclude_subtest` | Regex to **exclude** specific sub-tests. | `none` |

#### Execution Control

| Flag | Description | Default |
| --- | --- | --- |
| `--threads` | Space-separated list of concurrency levels (e.g., "1 4 8"). | `1 2` |
| `--time` | Duration (in seconds) per thread iteration. | `60` |
| `--events` | Number of transactions. **Overrides TIME if > 0.** | `0` |
| `--rate` | Transaction rate limit (TPS). 0 = unlimited. | *(Empty)* |
| `--reconnect` | Sysbench reconnect flag. | `0` |
| `--dryrun` | Print commands without executing. | `false` |

#### Observability & Profiling

| Flag | Description |
| --- | --- |
| `--havePMM` | Enable PMM annotations. |
| `--pmm_url` | URL for PMM Server (e.g., `http://admin:pass@1.2.3.4`). |
| `--pmm_node_name` | Node name to attach annotations to. |
| `--haveperf` | Enable `perf` recording and FlameGraph generation. |

---

## 💡 Examples

### 1. Basic Read-Only Sysbench

Runs standard Sysbench select tests against a "small" dataset for 60 seconds with 4 threads.

```bash
./run_bench_tests.sh \
  --testname sysbench \
  --command run \
  --type select \
  --sysbench_test_dimension small \
  --threads "4" \
  --time 60 \
  --host 127.0.0.1

```

### 2. Complex Join Test with Profiling

Runs a custom join test, limits execution to 20 events (instead of time), and generates a FlameGraph.

```bash
./run_bench_tests.sh \
  --testname joins \
  --command run \
  --type joins-select \
  --filter_subtest "simple_inner" \
  --events 20 \
  --threads "1 2" \
  --schemaname joins \
  --tablename main \
  --haveperf

```

*Note: This will output an `.svg` file in `/opt/results/joins/`.*

### 3. TPC-C Preparation

Prepares a TPC-C dataset with 100 warehouses.

```bash
./run_bench_tests.sh \
  --testname tpcc \
  --command prepare \
  --threads 4 \
  --schemaname tpcc_100w \
  --host 10.0.0.5

```

## 📂 Output & Logging

* **Logs:** Saved to `/opt/results/<testname>/`.
* Format: `TestName_Dimension_Type_RunID_Date.txt`


* **FlameGraphs:** If `--haveperf` is used, `.svg` files are generated in the same results directory.
* **Console:** Real-time output echoes the command being executed and the start/end times of every thread block.

## ⚠️ Important Notes

1. **Process Throttling:** The script includes a function `get_mysql_process_count`. If the number of running processes exceeds `MAX_THREADS_RUNNING_BETWEEN_TESTS` (Default: 20), the script will **sleep and wait** before starting the next test to prevent overloading a stalling database.
2. **Test Dimensions:**
* **Small:** 20 Tables, 10,000,000 rows each.
* **Large:** 5 Tables, 30,000,000 rows each.
* *(Modify `SYSNBENCH_ROWS_*` constants in the script to change this).*


### Parsing Results
- Use [sysbench graph creator](https://github.com/Tusamarco/sysbench-graph-creator/blob/main/README.md)

### Monitoring Results
- Use PMM via its web interface for real-time insights.

## Documentation and Reference Material
- [How to Prepare Benchmark Environment](docs/HOW_TO.md)
- [Action Plan](docs/plan.md)

## Contributing
Feel free to submit issues or pull requests. Follow the repository's contribution guidelines to ensure smooth collaboration.

## License
AGPL-3.0 license

## Acknowledgments
Powered and maintained by Tusamarco.

---
Happy benchmarking!
