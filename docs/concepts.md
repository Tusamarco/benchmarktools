# Benchmarking high level concepts and MySQL test definition

Created: October 31, 2023 7:18 PM
Tags: MySQL, benchmark, regression, testing
Created by: Marco Tusa
Date: October 31, 2023
Last edited by: Marco Tusa
Last edited time: November 14, 2023 9:23 AM

# Principles

Key factors:

- Relevant
- Repeatable
- Fair
- Economical
- Verifiable

## Relevant

- Collect relevant metrics
- Use relevant software for testing
- Use relevant Hardware/Environments

## Repeatable

- Confidence in getting same (or similar) results each test run
- Challenge when data differs. Identify the WHY behind and ask for a fix.
- Comparable starting point. IE data sets should be the same at each run. If test modify it, original condition must be restored.

## Fair

- Test design to fit a specific business model (no one for all)
- Declare clearly the scope
- Highlight the limits
- Multiple test run to identify variation
- Run to cover the default, do not try to cover the edge cases
- Use standard components
- Clearly state/indicate when special cases are covered as variation of the standard tests

## Verifiable

- Built confidence in the run test(s)
- Test produce self-verifiable results. IE test produce data that can be compare against verifiable criteria
- Test produce comparable results such that is possible to compare them also outside the specific case/run.
- Simple results to make verification easier

## Economical

- Tests must have a small cost footprint to be repeatable at any occurence
- Tests need to cover small scope to be modular. It doesn't make sense to run all if relevant changes cover just a small part.
- Components must be reusable, to avoid the need to build all from scratch at any run.

# Test scope

Multiple scope of testing:

- Stability
- Performance
- Saturation

## Stability

Stability tests measure the resiliency of the solution under different stress conditions:

- Internal component failure (Plugin/Component malfunction IE audit plugin, Encryption ... )
- Wrong component definition (like temporary space; wrong indexing; wrong data type )
- Environment instability (noise neighbourhood; power failure; storage crash )

## Saturation

- Identify how product behaves in relation to resource saturation given excessive load:
    - Memory
    - CPU
    - Storage

## Performance

Performance tests are focus on identify how the product behaves in relation to a growing traffic, without reaching saturation.
The tests should cover different scenarios business driven.
Tests should use standards such as TPC-C, TPC-H and similar or derivates.

## Regression tests

There is not such thing as regression tests.
That is just the comparison of standard tests across multiple version of the same software.
The comparison must be based on well consolidated tests, that had be proven to be consistent and provide trustable results.
When we have some diverging or conflictual data, then we should invest in a diversion/anomaly discovery project.
Which is a different exercise from standard benchmarking and should not impact the main exercise.

# Monitoring

Testing/Benchmarking should be supported by simple and monitoring able to give simple, immediate and actionable information.
This because while the exercise is NOT a performance tuning one, it is still important to identify if and where we have performance loss.
The important aspect is to identify if the setup/platform is eventually responsible of that, or if the software is the culprit.
In case the issues doesn't reside on the software we are testing, we need to remove/solve any issue before proceed.
If instead, the software itself is the responsible, then we should document the behaviour as clear as possible, creating repeatable test case.

# MySQL

MySQL is a RDBMS platform, as such the product should be tested against the following cases:

- Data Ingestion
- Light write heavy read load
- Transactional processing
- Analytical load

---

## Tests

## Data Ingestion

The scope of the test is to load as much data as possible in a given set of tables where the set is 1 to N tables.
Metric to collect:

- Execution time
- Insert/sec
- Latency 95%
- Data on disk
- Memory utilisation
- CPU utilisation
- Disk operations

Possible test software (IIBench [https://github.com/Dmitree-Max/sysbench-iibench](https://github.com/Dmitree-Max/sysbench-iibench))

Or original [https://github.com/mdcallag/mytools/blob/master/bench/ibench/iibench.py](https://github.com/mdcallag/mytools/blob/master/bench/ibench/iibench.py)

## Light write heavy read load

Scope of the test is to produce a synthetic load of ~95% reads and %5 writes. This reflect the common scenario of most websites.
Metric to collect:

- Execution time
- Insert/sec
- Read/sec
- Latency 95%
- Memory utilisation
- CPU utilisation
- Disk operations

Possible test software (sysbench and its variation) Sysbench with variation is a good fit.

## Transactional processing

This test follow the more well define scope of the TPC-C standard, where we application performs heavy transactional processing (OLTP).
In this case it is usual to have a 50/50% split between reads/writes.
Metric to collect:

- Execution time
- Insert/sec
- Read/sec
- Latency 95%
- Memory utilisation
- CPU utilisation
- Disk operations

Possible test software (software implementing TPC-C and/or TPC-E) Tpc - Sysbench is a good fit.

## Analytical load

Analytical test is a decision support benchmark. It consists of a suite of business oriented ad-hoc queries and concurrent data modifications. The queries and the data populating the database have been chosen to have broad industry-wide relevance. This benchmark illustrates decision support systems that examine large volumes of data, execute queries with a high degree of complexity, and give answers to critical business questions.
Metric to collect:

- Execution time
- ~~Insert/sec~~
- Read/sec
- ~~Latency 95%~~
- Memory utilisation
- CPU utilisation
- Disk operations

Possible test software (software implementing TPC-H or TPC-DS) like DBT3 

## Platforms

MySQL is currently available on several 'flavours':

- On premises
- In the cloud
- Container / kubernetes

Proper testing/benchmarking should allow to test all the different platforms, or in case not, to be very transparent and clear about the limits of the results.

## Operating System

MySQL is supported to run on a very large set of OSs, from Windows, MacOs to many different kind of Linux distributions.
While the differences between Windows and Linux solutions can be many and significant the differences between Linux distribution are suppose to be less impactful, once libraries versions are aligned.
Given so it is acceptable to use one of the major distribution (by family of OS) as leading platform and only use different ones in case of specific deviations.

## Implementations

[MySQL Plan of Action](plan.md)