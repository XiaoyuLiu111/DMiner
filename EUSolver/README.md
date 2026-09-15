# EUSolver Setup Instructions

### Pre-Requisites

- Python version 3.6.* is required. 
  - Installation for 3.6.15 can be found [here](https://www.python.org/downloads/release/python-3615/) 
  - For managing different python versions consider using [pyenv](https://github.com/pyenv/pyenv)
- Install cmake `sudo apt install cmake`

### Python Environment Setup

- Naviagte to EUSolver-graph directory and verify python version `python3 --version` and make sure it is 3.6.*
- Create virtual environment folder, create environment, and activate it by executing the following `mkdir .venv && python3 -m venv .venv && source ./.venv/bin/activate`


### Python Packages

- After activating virtual environment install packages with `pip install -r requirements.txt`

### Build and Run

- The project can now be build with `./scripts/build.sh` which will create the eusolver executable
- To test run `./eusolver benchmarks/cypher/tests/basic/match_path_return_node_test.sl` and verify the output matches the desired shown below

```
(define-fun f ((input Graph)) Graph
     (return (match input (createPathPattern (createNodePattern "n2" "Bank") (createEdgePattern "e1" "WORKS_AT" "<-") (createNodePattern "n1" "Person"))) "n1"))
```

# Code

### Important Graph Files

- `src/semantics/semantics_cypher.py`
  - Defines semantics for each of the operations in the grammar
  - Cypher clauses and queries are of Graph type and make calls to `src/utils/graph.py` for operations
  - Simpler operations are encoded as strings for interpretation in clauses and queries
- `src/utils/graph.py`
  - Contains `Graph` class to represents all graphs and associated methods for performing operations on graphs
  - All key operations including `Match`, `Filter`, and `Return` are implemented in this file
  - Individual methods are well documented in this file
- `src/utils/graph_functions.py`
  - Includes definitions for operations including aggregating functions and operations between expressions
  - Classes defined here are used in `Graph` class when evaluating expressions
- `src/parsers/sexp.py`
  - Contains parsing instructions for .sl files
  - Defines `Graph` type to be a string quoted in `<<` and `>>` to avoid any conflicts
- `src/parsers/parser.py`
  - Creates appropriate `Graph` objects from the parsed json strings

### Benchmark Scripts

- `benchmarks/cypher/benchmarks/`
  - Folder containing all of the raw benchmark data files
- `benchmarks/cypher/create_sl_files_from_demo.py`
  - Script to transform the raw benchmark files in `benchmarks/cypher/benchmarks/` into usable `*.sl` files for eusolver
- `benchmarks/cypher/sl_creator.py`
  - Contains util functions used in `benchmarks/cypher/create_sl_files_from_demo.py` to actually write the files
  - Must set hyperparameter here to decide how many free node/edge variables to give eusolver in the `sl` files
- `benchmarks/cypher/sl_files/`
  - Output of running `benchmarks/cypher/create_sl_files_from_demo.py`
  - All of these are `.sl` files that can be run by eusolver
- `benchmarks/cypher/demonstration_config_testing/`
  - A few handpicked benchmarks are turned into these config file wiht a desired query given
  - These are verified when the `test_all_queries.py` file is run 
    - This is discussed more in depth in the last section
- `benchmarks/cypher/run_sl_files.py`
  - Script used to run the `.sl` files generated in the above process and output results to `csv` file
  - Hyperparameter for the timeout length must be set in this file 

### Tests
- `benchmarks/cypher/tests/basic`
  - Tests for basic Match and Filter example queries
- `benchmarks/cypher/tests/aggregation`
  - Tests that involve aggregation
- `benchmarks/cypher/tests/operations`
  - Tests involving operations on expressions (addition and subtraction)
- `benchmarks/cypher/tests/combination`
  - More complex tests

### Verification Script
  - `test_all_queries.py`
    - Verifies that the 'correct' query does produce the correct output on the input/output graphs
    - Uses input graph, output graph, and correct query from the `benchmarks/benchmark_config/benchmark_*.txt` to run an verify that it is correct
    - Results of running are written to the `query_test_output.csv` file for review
  

### (OLD) Benchmark Scripts

- ```benchmarks/cypher/config-generation```
  - Folder containing files used to semi-autonomously generate benchmark config files
  - Due to python version incompatibilities the Python version to run the config generation script must be 3.7+. It is recommended to follow the steps outlined for EUSolver setup, but ensure that the python version is 3.7+. Install packages using the requirements.txt just as before.
  - `main.py`
    - Script that connects to neo4j instance with credentials provided in `database-config-txt` and runs queries from `queries.tsv` collecting metadata about the underlying graphs and constructing a benchmark config file
  - `database-config.txt`
    - Config file that is .gitignored so it must be created in the format shown below
    ```
    [database]
    BLANK_URI={URI FOR A BLANK NEO4J INSTANCE}
    BLANK_PASS={PASSWORD FOR THE BLANK INSTANCE}
    MOVIES_URI={URI FOR A PREMADE MOVIES NEO4J INSTANCE}
    MOVIES_PASS={PASSWORD FOR THE MOVIES INSTANCE}
    ```
  - `queries.tsv`
    - TSV file that contains a create query to create the input graph and a match query that will generate the output graph
  - `output/`
    - Default output directory for the config files generated by `main.py`
    - **Config files created by the script are not completed yet**
    - To complete them the OUTPUT_GRAPH line must be modified to match the desired output graph format
- `benchmarks/cypher/create_sl_files.py`
  - Creates .sl files from the config files given in `benchmark_config` and outputs them to `cypher-sl` folder
  - Contains the most up to date grammar so any changes must be made here
  - Has parameters about how many node/edge variables to use and can modify the output/input directories
- `benchmarks/cypher/run_sl_files.py`
  - Runs each of the .sl files in `cypher-sl` that were created by the `create_sl_files.py`
  - Contains parameters about how long to run each query before timing out
  - Will output the results to the `results.csv` file containing queries if they are succesfuly in synthesizing, else just a timeout message
- `results.csv`
  - Has the results of the most recent run of `run_sl_files.py`