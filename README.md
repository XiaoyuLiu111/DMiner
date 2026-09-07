**DMiner: Synthesizing graph queries from demonstrations through graph mining and deductive reasoning.**

DMiner is a **program synthesis tool that automatically constructs graph queries from user demonstrations**. Users provide small input graphs and tables of symbolic expressions describing their intended computations. DMiner infers the graph patterns, filtering conditions, and return expressions needed to construct a query consistent with those demonstrations.

The approach combines **graph mining with deductive reasoning** to make synthesis efficient. Graph mining discovers candidate query structures, while deductive reasoning turns output mismatches into logical constraints that eliminate entire families of incorrect candidates. Constraint optimization then constructs a concise filtering predicate, yielding an executable graph query in Cypher.

[Paper](https://doi.org/10.5281/zenodo.21913286)

## Workflow

<img width="720" height="190" alt="Slide1" src="https://github.com/user-attachments/assets/abe3994f-5de5-45c0-aa43-6c3d03c852dd" />



### Deductive reasoning at the core

Each stage narrows the gap between user intent and an executable query: demonstrations capture the desired computation, graph mining discovers relevant structure, and symbolic search explores candidate solutions. Evaluation checks consistency with the demonstrations, while constraint optimization favors concise queries.

**A failed candidate provides information for the next search step.** DMiner uses deductive reasoning to generalize an observed mismatch into logical constraints, ruling out entire families of incorrect candidates. This feedback loop reduces redundant exploration and focuses synthesis on the remaining possibilities. The paper’s ablation study measures the contribution of deduction and graph-mining pruning.

## Installation

The research artifact runs in **Docker**, with Neo4j for query evaluation.

- Tested on Linux with Docker **27.5.0**; Intel hardware is recommended by the artifact authors.
- Allocate **at least 15.5 GB RAM and more than 6 CPUs** to Docker. In Docker Desktop, use **Settings → Resources**.
- Download and extract the [artifact archive](https://doi.org/10.5281/zenodo.21930599), then open a terminal in its repository directory.

### 1. Load the image and start the container

Run on your **host machine** (approximately 3 minutes):

```bash
gunzip -c dminer-snapshot.tar.gz | docker load
docker compose up -d
```

Open the running `dminer` container’s terminal using **Docker Desktop → Exec**, or **Attach Shell** in the VS Code Docker extension. **Run all remaining commands inside the container.**

### 2. Load the data and compile

```bash
tar -C /data -xzf /database-snapshot/neo4j-data.tar.gz
chmod +x /scripts/start.sh
/scripts/start.sh
neo4j start
```

Wait about a minute for Neo4j to become ready, then verify the data:

```bash
cypher-shell -u neo4j -p pswd1234 -d experiment9demonstration0 \
  "MATCH (n) RETURN count(n);"
```

Expected node count: **8**. The credentials above belong to the bundled experiment database.

### 3. Run a smoke test

Confirm Neo4j is running with `neo4j status`, then run:

```bash
chmod +x /scripts/kick-the-tire.sh
/scripts/kick-the-tire.sh
```

Outputs:

- DMiner: `/DMINER_Artifact/experiments/results/mainResults.json`
- EUSolver: `/EUSolver/benchmarks/cypher/test_results.out`

## Reproduce the results

Keep Neo4j running throughout evaluation. If necessary, run `neo4j start` and wait about a minute before continuing. The supplied Docker configuration mounts experiment results back to the host.

### 1. DMiner and ablations

```bash
chmod +x /scripts/run_eval.sh
/scripts/run_eval.sh
```

Runs DMiner and variants without graph-mining pruning, deductive reasoning, or both. The default timeout is **600 seconds per benchmark**; the documented total runtime is approximately **2.5 hours**. Results are written to `/DMINER_Artifact/experiments/results`.

### 2. EUSolver baseline

```bash
cd /EUSolver
source .venv/bin/activate
.venv/bin/python /EUSolver/benchmarks/cypher/run_sl_files.py 600
```

Allow approximately **2.5 hours** with the 600-second timeout. Results are written to `/EUSolver/benchmarks/cypher/results.out`.

### 3. Generate tables and figures

```bash
mkdir -p /DMINER_Artifact/experiments/results/tables_and_figures
chmod +x /DMINER_Artifact/experiments/scripts/plotFiguresTables.sh
/DMINER_Artifact/experiments/scripts/plotFiguresTables.sh
```

Generated files are in `/DMINER_Artifact/experiments/results/tables_and_figures`:

| Output | What to check |
| --- | --- |
| `Table1.csv` | Benchmark statistics agree with the paper. |
| `Figure14.pdf` | Complex tasks generally require more synthesis time than simple tasks. |
| `Figure15.pdf`, `Figure16.pdf` | Full DMiner outperforms the ablated variants. |
| `Table2.csv` | Baseline comparison; timing varies with hardware. |

To print the average DMiner synthesis time:

```bash
python /DMINER_Artifact/experiments/scripts/average.py
```

The paper reports approximately **0.6 seconds**; the artifact guide allows roughly **0.6–2 seconds** under Docker. These commands rerun DMiner, its ablations, and EUSolver. The supplied installation guide does not provide instructions for rerunning the paper’s LLM baselines.

## Try your own demonstration

Add a row to `/DMINER_Artifact/experiments/reusability/newQuery.tsv` with an unused benchmark ID greater than 100. Each row supports up to four demonstrations, pairing `query1`–`query4` (Cypher `CREATE` queries) with `Output1`–`Output4` (symbolic output tables).

Assign a unique `id` to every node and edge within each demonstration. In output expressions, use `n<id>` for nodes and `e<id>` for edges; keep expressions symbolic, such as `[(n1.age - n3.age)]`.

```bash
# Replace 101 with the ID you added.
chmod +x /DMINER_Artifact/experiments/reusability/run_benchmark.sh
/DMINER_Artifact/experiments/reusability/run_benchmark.sh 101
```

The synthesized query is saved under `/DMINER_Artifact/experiments/results/new_benchmarks`; validation against the supplied demonstrations is printed in the terminal.

DMiner currently supports a subset of Cypher and assumes correct demonstrations. Unsupported features include multiple `MATCH` clauses, variable-length patterns, aggregation filtering, and subqueries.
