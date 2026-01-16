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

### Parsing Results
- Use [`read_and_get_from_file.sh` for log parsing and insights extraction.](https://github.com/Tusamarco/sysbench-graph-creator)

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
