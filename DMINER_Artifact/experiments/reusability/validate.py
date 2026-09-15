"""Validate synthesized Cypher queries on the reusability benchmarks.

This script
evaluates those expressions using the entities in each demonstration database,
runs the synthesized query, and compares the two result tables.
"""

import argparse
import ast
import csv
import json
import math
import sys
import re
from collections import Counter
from pathlib import Path
import os
import configparser
from typing import Any, Dict, Iterable, List, Mapping, Optional, Sequence, Tuple


try:
    from neo4j.graph import Node, Path as Neo4jPath, Relationship
except ImportError:  # Allows the pure comparison helpers to be imported in tests.
    Node = Relationship = Neo4jPath = ()


SCRIPT_DIRECTORY = Path(__file__).resolve().parent
DEFAULT_RESULTS_DIRECTORY = SCRIPT_DIRECTORY.parent / "results" / "new_benchmarks"
DEFAULT_EXPECTED_FILE = SCRIPT_DIRECTORY / "newQuery.tsv"
MAX_DEMONSTRATIONS = 4

class GraphDB():
    '''
    Class to manage database operations
    '''

    def __init__(self, connection_uri, db_auth, database_name: str) -> None:
        from neo4j import GraphDatabase

        self.driver = GraphDatabase.driver(connection_uri, auth=db_auth)
        self.database_name = database_name
        self.input_graph = None

    def exec_query(self, query: str) -> tuple:
        with self.driver.session(database=self.database_name) as session:
            result = session.run(query)
            keys = result.keys()
            records = list(result)
            summary = result.consume()
        return records, summary, keys

    def create_database(self) -> None:
        escaped_database_name = self.database_name.replace('`', '``')
        with self.driver.session(database='system') as session:
            session.run(
                f'CREATE DATABASE `{escaped_database_name}` IF NOT EXISTS WAIT'
            ).consume()

    def clear_graph(self) -> None:
        self.exec_query('MATCH (n) DETACH DELETE n')

    def get_full_graph(self) -> tuple:
        '''
        Creates a list of nodes/relationships represented in dictionary and returns colleciont
        '''
        records, _, _ = self.exec_query(
            'MATCH (n) RETURN n UNION MATCH ()-[n]-() RETURN n'
        )

        graph, nodes, edges = {}, [], []

        for record in records:
            for r in record:
                try:
                    if isinstance(r, Node):
                        node = self.create_node_representation(r)
                        nodes.append(node)
                    else:
                        edge = self.create_relationships_representation(r)
                        edges.append(edge)

                except Exception as e:
                    print(f'Error getting full graph: {e}')

        graph['nodes'] = nodes
        graph['edges'] = edges
        self.input_graph = graph
        return graph

    # UTIL FUNCTIONS
    @staticmethod
    def get_entity_id(entity) -> str:
        """Return an ID with both Neo4j 4.x and 5.x drivers."""
        element_id = getattr(entity, 'element_id', None)
        if element_id is not None:
            parts = element_id.split(':')
            return parts[2] if len(parts) > 2 else element_id
        return str(entity.id)

    def create_node_representation(self, n: Node) -> dict:
        node = {
            'element_id': self.get_entity_id(n),
            'label': list(n.labels)[0],
        }

        for key in n.keys():
            value = n[key]

            if isinstance(value, list):
                value = [x.replace('"', '') for x in value]

            node[key] = value

        return node

    def create_relationships_representation(self, r: Relationship) -> dict:
        edge = {
            'label': r.type,
            'element_id': self.get_entity_id(r),
            'start': self.get_entity_id(r.start_node),
            'end': self.get_entity_id(r.end_node),
        }

        for key in r.keys():
            value = r[key]

            if isinstance(value, list):
                value = [x.replace('"', '') for x in value]

            edge[key] = value

        return edge


def get_base_connection() -> Tuple[str, object]:
    from neo4j import basic_auth

    script_directory = os.path.dirname(os.path.abspath(__file__))
    config_file = os.path.join(
        os.path.dirname(script_directory),
        'experiments.config',
    )

    if not os.path.isfile(config_file):
        raise FileNotFoundError(
            'Neo4j connection configuration was not found: {}'.format(config_file)
        )

    with open(config_file, encoding='utf-8') as config_handle:
        config_text = config_handle.read()

    # experiments.config contains URI/PASSWORD entries without an INI section.
    config_parser = configparser.RawConfigParser()
    config_parser.read_string('[database]\n' + config_text)

    base_connection_uri = config_parser.get('database', 'URI').strip()
    base_password = config_parser.get('database', 'PASSWORD').strip()

    if not base_connection_uri:
        raise ValueError('URI is empty in {}'.format(config_file))
    if not base_password:
        raise ValueError('PASSWORD is empty in {}'.format(config_file))

    base_db_auth = basic_auth('neo4j', base_password)
    return base_connection_uri, base_db_auth


def build_element_id_mapping_file(benchmark_id: str, output_directory: str) -> None:
    script_directory = os.path.dirname(__file__)
    helper_directory = os.path.join(script_directory, 'helper')
    helper_script = os.path.join(helper_directory, 'build_element_id_mappings.py')
    benchmark_file = os.path.join(output_directory, f'benchmark{benchmark_id}.json')
    output_mapping_file = os.path.join(
        helper_directory,
        f'benchmark{benchmark_id}_element_id_mappings.json',
    )

    if not os.path.exists(helper_script):
        raise FileNotFoundError(
            'Element id helper script was not found: {}'.format(helper_script)
        )
    if not os.path.exists(benchmark_file):
        raise FileNotFoundError(
            'Benchmark file was not found: {}'.format(benchmark_file)
        )

    spec = importlib.util.spec_from_file_location(
        'build_element_id_mappings',
        helper_script,
    )
    helper_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper_module)

    mappings = helper_module.build_mappings(benchmark_file)
    if not os.path.isdir(helper_directory):
        os.makedirs(helper_directory)

    with open(output_mapping_file, 'w', encoding='utf-8') as output_handle:
        json.dump(mappings, output_handle, ensure_ascii=False, indent=4)
        output_handle.write('\n')

    print('Saved mappings to {}'.format(output_mapping_file))


def remove_id_fields(data):
    if isinstance(data, list):
        return [remove_id_fields(item) for item in data]
    if isinstance(data, dict):
        return {
            key: remove_id_fields(value)
            for key, value in data.items()
            if key != 'id'
        }
    return data


def writer_input_helper(base_url: str, base_auth, row: List[str], row_idx: int, output_directory="output") -> None:

    try:
        benchmarkID, create_query_1, create_query_2, create_query_3, create_query_4 = row[0].strip('"'), row[1].strip('"'), row[2].strip('"'), row[3].strip('"'), row[4].strip('"')
        queries = {0: create_query_1, 1: create_query_2, 2: create_query_3, 3: create_query_4}
        
        datas = {}
        for demonstrationID in range(4):
            if queries[demonstrationID]!="":
                datas[demonstrationID] = {"inputGraph": None, "mapping1":None, "mapping2":None, "mapping3":[]}
                database_name = "experiment"+str(benchmarkID)+"demonstration"+str(demonstrationID)
                db = GraphDB(base_url, base_auth, database_name)
                try:
                    db.create_database()
                    db.clear_graph()
                    # TODO: More than one create query in different databases
                    db.exec_query(queries[demonstrationID])

                    # query our start graph and execute the query to get the output
                    input_data = db.get_full_graph()
                    datas[demonstrationID]["inputGraph"] = input_data
                finally:
                    db.driver.close()
        
        benchmark_data = load_benchmark_output_file(output_directory, benchmarkID)
        demonstrations = benchmark_data.setdefault('demonstrations', [])
        for demonstrationID in range(4):
            if queries[demonstrationID] != "":
                while len(demonstrations) <= demonstrationID:
                    demonstrations.append({})
                demonstrations[demonstrationID]['inputGraph'] = datas[demonstrationID]["inputGraph"]
        save_benchmark_output_file(output_directory, benchmarkID, benchmark_data, remove_ids=False)
        build_element_id_mapping_file(benchmarkID, output_directory)
        save_benchmark_output_file(output_directory, benchmarkID, benchmark_data)
        print(f"successful in benchmark {benchmarkID}")
    except Exception as e:
        print(e)


def benchmark_matches(row_benchmark_id: str, selected_benchmark_id: Optional[str]) -> bool:
    if not selected_benchmark_id:
        return True
    return row_benchmark_id.strip().strip('"') == selected_benchmark_id.strip().strip('"')


def write_input_to_file(base_url: str, base_auth, input_file: str,
                               output_directory="output", benchmark_id: Optional[str] = None) -> None:
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    matched_benchmark = False
    with open(input_file) as tsv:
        reader = csv.reader(tsv, dialect='excel-tab')
        next(reader)

        for i, row in enumerate(reader):
            i += 2
            if not row or not benchmark_matches(row[0], benchmark_id):
                continue
            matched_benchmark = True
            writer_input_helper(base_url, base_auth, row, i, output_directory)

    if benchmark_id and not matched_benchmark:
        print(f'No row found for benchmarkID {benchmark_id}')


OPERATOR_PATTERN = re.compile(
    r'\b(?:max|min|count|avg|average|sum)\s*\(|[+\-*/]',
    re.IGNORECASE,
)
PLAIN_EXPRESSION_PATTERN = re.compile(r'^([a-zA-Z]+)(\d+)(?:\.([a-zA-Z_][a-zA-Z0-9_]*))?$')


def parse_demonstration_table(table_text: str) -> List[List[str]]:
    table_text = table_text.strip()
    if not table_text:
        return []

    try:
        table = ast.literal_eval(table_text)
    except (ValueError, SyntaxError):
        try:
            table = json.loads(table_text)
        except ValueError:
            return parse_unquoted_demonstration_table(table_text)

    if not isinstance(table, list):
        raise ValueError(f'Demonstration table must be a list of rows: {table_text}')

    normalized_table = []
    for row in table:
        if not isinstance(row, (list, tuple)):
            raise ValueError(f'Demonstration table row must be a list or tuple: {row}')
        normalized_table.append([str(expression).strip() for expression in row])
    return normalized_table


def parse_unquoted_demonstration_table(table_text: str) -> List[List[str]]:
    table_text = table_text.strip()
    if not (table_text.startswith('[') and table_text.endswith(']')):
        raise ValueError(f'Demonstration table must be wrapped in []: {table_text}')

    body = table_text[1:-1].strip()
    if not body:
        return []

    normalized_table = []
    for row_text in split_top_level_commas(body):
        row_text = strip_wrapping_parentheses(row_text)
        normalized_table.append(split_top_level_commas(row_text))
    return normalized_table


def has_operator(expression: str) -> bool:
    return OPERATOR_PATTERN.search(expression) is not None


def parse_plain_expression(expression: str) -> Tuple[str, str, str]:
    match = PLAIN_EXPRESSION_PATTERN.match(expression.strip())
    if not match:
        raise ValueError(f'Unsupported plain expression: {expression}')

    entity_prefix, entity_id, property_name = match.groups()
    property_name = property_name or 'full'
    mapping_key = 'nodes' if entity_prefix.lower().startswith('n') else 'edges'
    return mapping_key, entity_id, property_name


def get_element_id_for_entity(mapping_key: str, entity_id: str, element_id_mapping: Optional[dict] = None) -> str:
    if not element_id_mapping:
        return entity_id
    return element_id_mapping.get(mapping_key, {}).get(
        'id_to_element_id',
        {},
    ).get(entity_id, entity_id)


def parse_entity_expression(expression: str, element_id_mapping: Optional[dict] = None) -> Tuple[str, str]:
    match = PLAIN_EXPRESSION_PATTERN.match(expression.strip())
    if not match:
        raise ValueError(f'Unsupported expression item: {expression}')

    entity_prefix, entity_id, property_name = match.groups()
    mapping_key = 'nodes' if entity_prefix.lower().startswith('n') else 'edges'
    entity_id = get_element_id_for_entity(mapping_key, entity_id, element_id_mapping)
    return f'{entity_prefix}{entity_id}', property_name or 'full'


def add_plain_expression_mapping(
    expression: str,
    output_id: int,
    mapping1: Dict[str, List[dict]],
    mapping2: Dict[str, List[dict]],
    element_id_mapping: Optional[dict] = None,
) -> None:
    mapping_key, entity_id, property_name = parse_plain_expression(expression)
    entity_id = get_element_id_for_entity(mapping_key, entity_id, element_id_mapping)
    mapping1[mapping_key].append({'output': output_id, 'input': [[entity_id], '']})
    mapping2[mapping_key].append({'output': output_id, 'property': property_name})


def strip_wrapping_parentheses(expression: str) -> str:
    expression = expression.strip()
    while expression.startswith('(') and expression.endswith(')'):
        depth = 0
        wraps_expression = True
        for index, char in enumerate(expression):
            if char == '(':
                depth += 1
            elif char == ')':
                depth -= 1
                if depth == 0 and index != len(expression) - 1:
                    wraps_expression = False
                    break

        if not wraps_expression:
            break
        expression = expression[1:-1].strip()
    return expression


def split_top_level_operator(expression: str, operators: str) -> Optional[Tuple[str, str, str]]:
    depth = 0
    for index in range(len(expression) - 1, -1, -1):
        char = expression[index]
        if char == ')':
            depth += 1
        elif char == '(':
            depth -= 1
        elif depth == 0 and char in operators:
            if char in '+-' and (index == 0 or expression[index - 1] in '+-*/('):
                continue
            return expression[:index], char, expression[index + 1:]
    return None


def split_top_level_commas(expression: str) -> List[str]:
    parts = []
    depth = 0
    start = 0
    for index, char in enumerate(expression):
        if char == '(':
            depth += 1
        elif char == ')':
            depth -= 1
        elif depth == 0 and char == ',':
            parts.append(expression[start:index].strip())
            start = index + 1
    parts.append(expression[start:].strip())
    return [part for part in parts if part]


class ValidationResult:
    def __init__(
        self,
        benchmark_id: str,
        demonstration_id: int,
        status: str,
        expected: Optional[List[Tuple[Any, ...]]] = None,
        actual: Optional[List[Tuple[Any, ...]]] = None,
        error: Optional[str] = None,
    ) -> None:
        self.benchmark_id = benchmark_id
        self.demonstration_id = demonstration_id
        self.status = status
        self.expected = expected
        self.actual = actual
        self.error = error


class ExpectedExpressionEvaluator:
    """Safely evaluate the small expression language used by newQuery.tsv."""

    AGGREGATES = {
        "max": max,
        "min": min,
        "sum": sum,
        "count": lambda values: len(values),
        "avg": lambda values: sum(values) / len(values) if values else None,
        "average": lambda values: sum(values) / len(values) if values else None,
    }

    def __init__(self, driver, database_name: str) -> None:
        self.driver = driver
        self.database_name = database_name
        self.entities: Dict[Tuple[str, int], Any] = {}

    def evaluate(self, expression: str) -> Any:
        tree = ast.parse(expression.strip(), mode="eval")
        return self._evaluate_node(tree.body)

    def _entity(self, prefix: str, entity_id: int) -> Any:
        key = (prefix.lower(), entity_id)
        if key in self.entities:
            return self.entities[key]

        variable = "n" if prefix.lower().startswith("n") else "r"
        pattern = f"({variable} {{id: $entity_id}})"
        if variable == "r":
            pattern = f"()-[{variable} {{id: $entity_id}}]-()"
        query = f"MATCH {pattern} RETURN DISTINCT {variable}"
        with self.driver.session(database=self.database_name) as session:
            records = list(session.run(query, entity_id=entity_id))
        if len(records) != 1:
            raise ValueError(
                f"Expected one {prefix}{entity_id} in {self.database_name}, "
                f"found {len(records)}"
            )
        self.entities[key] = records[0][variable]
        return self.entities[key]

    def _evaluate_node(self, node: ast.AST) -> Any:
        if isinstance(node, ast.Constant):
            return node.value
        if isinstance(node, ast.Name):
            prefix, entity_id = parse_entity_name(node.id)
            return self._entity(prefix, entity_id)
        if isinstance(node, ast.Attribute):
            entity = self._evaluate_node(node.value)
            if not isinstance(node.value, ast.Name):
                raise ValueError("Properties may only be read from an entity")
            try:
                return entity[node.attr]
            except KeyError as exc:
                raise ValueError(f"Entity has no property {node.attr!r}") from exc
        if isinstance(node, ast.UnaryOp) and isinstance(node.op, (ast.UAdd, ast.USub)):
            value = self._evaluate_node(node.operand)
            return value if isinstance(node.op, ast.UAdd) else -value
        if isinstance(node, ast.BinOp):
            lhs = self._evaluate_node(node.left)
            rhs = self._evaluate_node(node.right)
            if isinstance(node.op, ast.Add):
                return lhs + rhs
            if isinstance(node.op, ast.Sub):
                return lhs - rhs
            if isinstance(node.op, ast.Mult):
                return lhs * rhs
            if isinstance(node.op, ast.Div):
                return lhs / rhs
            raise ValueError(f"Unsupported arithmetic operator: {type(node.op).__name__}")
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
            name = node.func.id.lower()
            if name not in self.AGGREGATES or node.keywords:
                raise ValueError(f"Unsupported function: {node.func.id}")
            values = [self._evaluate_node(argument) for argument in node.args]
            return self.AGGREGATES[name](values)
        raise ValueError(f"Unsupported expected-output expression: {ast.dump(node)}")


def parse_entity_name(name: str) -> Tuple[str, int]:
    prefix_length = 0
    while prefix_length < len(name) and name[prefix_length].isalpha():
        prefix_length += 1
    prefix, entity_id = name[:prefix_length], name[prefix_length:]
    if not prefix or not entity_id.isdigit() or prefix[0].lower() not in {"n", "e", "r"}:
        raise ValueError(f"Unsupported entity reference: {name}")
    return prefix, int(entity_id)


def normalize_value(value: Any) -> Any:
    """Convert Neo4j and Python values to a stable, hashable representation."""
    if isinstance(value, Node):
        return (
            "node",
            tuple(sorted(value.labels)),
            normalize_value(dict(value)),
        )
    if isinstance(value, Relationship):
        return (
            "relationship",
            value.type,
            normalize_value(dict(value)),
            normalize_value(value.start_node),
            normalize_value(value.end_node),
        )
    if isinstance(value, Neo4jPath):
        return (
            "path",
            tuple(normalize_value(node) for node in value.nodes),
            tuple(normalize_value(edge) for edge in value.relationships),
        )
    if isinstance(value, Mapping):
        return tuple(sorted((str(key), normalize_value(item)) for key, item in value.items()))
    if isinstance(value, (list, tuple)):
        return tuple(normalize_value(item) for item in value)
    if isinstance(value, set):
        return tuple(sorted(normalize_value(item) for item in value))
    if isinstance(value, float) and math.isnan(value):
        return ("float", "nan")
    try:
        hash(value)
    except TypeError:
        return repr(value)
    return value


def normalize_rows(rows: Iterable[Iterable[Any]]) -> List[Tuple[Any, ...]]:
    return [tuple(normalize_value(value) for value in row) for row in rows]


def bag_equal(expected: Sequence[Tuple[Any, ...]], actual: Sequence[Tuple[Any, ...]]) -> bool:
    """Compare tables up to permutations of both rows and columns.

    Row multiplicity is preserved.  A column can only be paired with an actual
    column having the same bag of values; the final row-bag check ensures that
    independently similar columns do not create a false match.
    """
    if len(expected) != len(actual):
        return False
    if not expected:
        return True

    expected_width = len(expected[0])
    actual_width = len(actual[0])
    if expected_width != actual_width:
        return False
    if any(len(row) != expected_width for row in expected):
        return False
    if any(len(row) != actual_width for row in actual):
        return False

    expected_columns = [
        Counter(row[index] for row in expected)
        for index in range(expected_width)
    ]
    actual_columns = [
        Counter(row[index] for row in actual)
        for index in range(actual_width)
    ]
    candidates = [
        [
            actual_index
            for actual_index, actual_column in enumerate(actual_columns)
            if expected_column == actual_column
        ]
        for expected_column in expected_columns
    ]
    if any(not options for options in candidates):
        return False

    # Try the most constrained expected columns first to avoid unnecessary
    # permutations when several columns contain similar values.
    search_order = sorted(range(expected_width), key=lambda index: len(candidates[index]))
    mapping = [None] * expected_width

    def has_matching_mapping(depth: int, used_actual_columns: set) -> bool:
        if depth == expected_width:
            reordered_actual = [
                tuple(row[mapping[index]] for index in range(expected_width))
                for row in actual
            ]
            return Counter(expected) == Counter(reordered_actual)

        expected_index = search_order[depth]
        for actual_index in candidates[expected_index]:
            if actual_index in used_actual_columns:
                continue
            mapping[expected_index] = actual_index
            used_actual_columns.add(actual_index)
            if has_matching_mapping(depth + 1, used_actual_columns):
                return True
            used_actual_columns.remove(actual_index)
            mapping[expected_index] = None
        return False

    return has_matching_mapping(0, set())


def load_expected_rows(path: Path) -> Dict[str, Dict[int, str]]:
    expected: Dict[str, Dict[int, str]] = {}
    with path.open(encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle, dialect="excel-tab"):
            benchmark_id = row["benchmarkID"].strip().strip('"')
            outputs = {
                index: row.get(f"Output{index + 1}", "").strip()
                for index in range(MAX_DEMONSTRATIONS)
                if row.get(f"Output{index + 1}", "").strip()
            }
            expected[benchmark_id] = outputs
    return expected


def iter_result_files(path: Path) -> Iterable[Path]:
    if path.is_file():
        yield path
    elif path.is_dir():
        yield from sorted(path.rglob("*.json"))
    else:
        raise FileNotFoundError(f"Results path does not exist: {path}")


def load_synthesized_programs(
    path: Path,
    benchmark_filter: Optional[str] = None,
) -> Dict[str, Optional[str]]:
    programs: Dict[str, Optional[str]] = {}
    normalized_filter = (
        benchmark_filter.strip().strip('"')
        if benchmark_filter is not None
        else None
    )
    for result_file in iter_result_files(path):
        if result_file.stat().st_size == 0:
            continue
        with result_file.open(encoding="utf-8") as handle:
            document = json.load(handle)
        entries = document if isinstance(document, list) else [document]
        for entry in entries:
            if not isinstance(entry, dict) or "benchmarkID" not in entry:
                continue
            benchmark_id = str(entry["benchmarkID"])
            if normalized_filter is not None and benchmark_id != normalized_filter:
                continue
            program = entry.get("Synthesized") or entry.get("synthesized")
            # Result files are append-only. Later entries represent newer runs,
            # so validation uses only the final entry for each benchmark.
            programs[benchmark_id] = program
    return programs


def expected_values(
    table_text: str, evaluator: ExpectedExpressionEvaluator
) -> List[Tuple[Any, ...]]:
    expression_rows = parse_demonstration_table(table_text)
    return normalize_rows(
        [evaluator.evaluate(expression) for expression in row]
        for row in expression_rows
    )


def validate(
    expected_file: Path,
    results_path: Path,
    connection_uri: str,
    authentication: Any,
    benchmark_filter: Optional[str] = None,
) -> List[ValidationResult]:
    normalized_filter = (
        benchmark_filter.strip().strip('"')
        if benchmark_filter is not None
        else None
    )
    expected_by_benchmark = load_expected_rows(expected_file)
    programs = load_synthesized_programs(
        results_path,
        benchmark_filter=normalized_filter,
    )
    results: List[ValidationResult] = []

    benchmark_ids = sorted(expected_by_benchmark, key=lambda item: int(item))
    if normalized_filter is not None:
        benchmark_ids = [item for item in benchmark_ids if item == normalized_filter]
        if not benchmark_ids:
            raise ValueError(
                f"Benchmark {normalized_filter} is not present in {expected_file}"
            )

    for benchmark_id in benchmark_ids:
        program = programs.get(benchmark_id)
        for demonstration_id, table_text in expected_by_benchmark[benchmark_id].items():
            if not program:
                results.append(
                    ValidationResult(benchmark_id, demonstration_id, "not_synthesized")
                )
                continue

            database_name = f"experiment{benchmark_id}Demonstration{demonstration_id}"
            database = GraphDB(connection_uri, authentication, database_name)
            try:
                evaluator = ExpectedExpressionEvaluator(database.driver, database_name)
                expected = expected_values(table_text, evaluator)
                records, _, _ = database.exec_query(program)
                actual = normalize_rows(tuple(record.values()) for record in records)
                results.append(
                    ValidationResult(
                        benchmark_id,
                        demonstration_id,
                        "match" if bag_equal(expected, actual) else "mismatch",
                        expected,
                        actual,
                    )
                )
            except Exception as exc:
                results.append(
                    ValidationResult(
                        benchmark_id,
                        demonstration_id,
                        "error",
                        error=f"{type(exc).__name__}: {exc}",
                    )
                )
            finally:
                database.driver.close()
    return results


def print_results(results: Sequence[ValidationResult]) -> None:
    for result in results:
        label = f"benchmark {result.benchmark_id}, demonstration {result.demonstration_id + 1}"
        print(f"{label}: {result.status}")
        if result.status == "mismatch":
            expected_bag, actual_bag = Counter(result.expected or []), Counter(result.actual or [])
            print(f"  missing: {list((expected_bag - actual_bag).elements())}")
            print(f"  unexpected: {list((actual_bag - expected_bag).elements())}")
        elif result.error:
            print(f"  {result.error}")

    counts = Counter(result.status for result in results)
    summary = ", ".join(f"{status}={count}" for status, count in sorted(counts.items()))
    print(f"Summary: {summary or 'no demonstrations'}")


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Run synthesized queries and compare their results as bags."
    )
    parser.add_argument("--results", type=Path, default=DEFAULT_RESULTS_DIRECTORY)
    parser.add_argument("--expected", type=Path, default=DEFAULT_EXPECTED_FILE)
    parser.add_argument("--benchmarkID", help="Validate only one benchmark ID")
    args = parser.parse_args(argv)

    try:
        connection_uri, authentication = get_base_connection()
        results = validate(
            args.expected,
            args.results,
            connection_uri,
            authentication,
            benchmark_filter=args.benchmarkID,
        )
    except Exception as exc:
        print(f"Validation failed: {type(exc).__name__}: {exc}", file=sys.stderr)
        return 2

    print_results(results)
    unsuccessful = {"mismatch", "error", "not_synthesized"}
    return 1 if any(result.status in unsuccessful for result in results) else 0


if __name__ == "__main__":
    raise SystemExit(main())
