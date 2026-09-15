# from __future__ import annotations

import csv
import os
import json
import configparser
import argparse
import ast
import re
import importlib.util
from collections import defaultdict
from typing import Dict, List, Optional, Tuple

try:
    from neo4j.graph import Node, Relationship
except ImportError:
    Node = Relationship = object


'''
Overall Description

Reads in a tsv file and for each of the benchmarks in the tsv file it will create an input and output.

'''


class CypherType():
    '''
    Represents an object in our input/output graphs
    '''

    def __init__(self, properties: dict) -> None:
        self.properties = properties

    def get_property(self, property):
        if property in self.properties:
            return self.properties[property]

        return None

    def to_dict(self):
        return self.properties

    def __hash__(self):
        return len(self.properties)

    def __eq__(self, other):
        return self.properties == other.properties


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


def make_mapping3_item(operator: str, property_name: str, data: List[str], lhs=None, rhs=None) -> dict:
    return {
        'operator': operator,
        'property': property_name,
        'data': data,
        'lhs': lhs or {},
        'rhs': rhs or {},
    }


def parse_aggregate_expression(expression: str, element_id_mapping: Optional[dict] = None) -> Optional[dict]:
    match = re.match(
        r'^(max|min|count|avg|average|sum)\((.*)\)$',
        expression,
        re.IGNORECASE,
    )
    if not match:
        return None

    operator, argument_text = match.groups()
    operator = operator.lower()
    if operator == 'average':
        operator = 'avg'
    data = []
    properties = []
    for argument in split_top_level_commas(argument_text):
        item, property_name = parse_entity_expression(argument, element_id_mapping)
        data.append(item)
        properties.append(property_name)

    property_name = next((property_item for property_item in properties if property_item != 'full'), 'full')
    return make_mapping3_item(operator, property_name, data)


def parse_mapping3_expression(expression: str, element_id_mapping: Optional[dict] = None) -> dict:
    expression = strip_wrapping_parentheses(expression)

    for operators in ('+-', '*/'):
        split_expression = split_top_level_operator(expression, operators)
        if split_expression:
            lhs, operator, rhs = split_expression
            return make_mapping3_item(
                operator,
                '',
                [],
                lhs=parse_mapping3_expression(lhs, element_id_mapping),
                rhs=parse_mapping3_expression(rhs, element_id_mapping),
            )

    aggregate_item = parse_aggregate_expression(expression, element_id_mapping)
    if aggregate_item:
        return aggregate_item

    item, property_name = parse_entity_expression(expression, element_id_mapping)
    return make_mapping3_item('empty', property_name, [item])


def correspondence_item(expression: str, mapping3_id: int) -> str:
    if has_operator(expression):
        return f'exp{mapping3_id}'

    item, _ = parse_entity_expression(expression)
    return item


def process_demonstration_table(table_text: str, element_id_mapping: Optional[dict] = None) -> dict:
    mapping1 = {'nodes': [], 'edges': []}
    mapping2 = {'nodes': [], 'edges': []}
    mapping3 = []
    correspondence = []
    output_id = 0
    mapping3_id = 0

    for row in parse_demonstration_table(table_text):
        correspondence_row = []
        for expression in row:
            if not expression:
                continue
            if has_operator(expression):
                mapping3.append(parse_mapping3_expression(expression, element_id_mapping))
                correspondence_row.append(correspondence_item(expression, mapping3_id))
                mapping3_id += 1
            else:
                add_plain_expression_mapping(
                    expression,
                    output_id,
                    mapping1,
                    mapping2,
                    element_id_mapping=element_id_mapping,
                )
                correspondence_row.append(f'n{output_id}')
            output_id += 1
        if correspondence_row:
            correspondence.append(correspondence_row)

    return {'mapping1': mapping1, 'mapping2': mapping2, 'mapping3': mapping3, 'correspondence': correspondence}


def load_benchmark_output_file(output_directory: str, benchmark_id: str) -> dict:
    output_file = os.path.join(output_directory, f'benchmark{benchmark_id}.json')
    if not os.path.exists(output_file):
        return {'demonstrations': []}

    with open(output_file, encoding='utf-8') as f:
        return json.load(f)


def load_element_id_mappings(benchmark_id: str) -> List[dict]:
    script_directory = os.path.dirname(__file__)
    mapping_file = os.path.join(
        script_directory,
        'helper',
        f'benchmark{benchmark_id}_element_id_mappings.json',
    )
    if not os.path.exists(mapping_file):
        return []

    with open(mapping_file, encoding='utf-8') as f:
        mapping_data = json.load(f)

    return mapping_data.get('demonstrations', [])


def get_demonstration_element_id_mapping(element_id_mappings: List[dict], demonstration_id: int) -> Optional[dict]:
    for mapping_item in element_id_mappings:
        if mapping_item.get('demonstration_id') == demonstration_id:
            return mapping_item
    return None


def save_benchmark_output_file(output_directory: str, benchmark_id: str, data: dict, remove_ids: bool = True) -> None:
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    output_file = os.path.join(output_directory, f'benchmark{benchmark_id}.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        output_data = remove_id_fields(data) if remove_ids else data
        json.dump(output_data, f, ensure_ascii=False, indent=4)


def writer_output_helper(row: Dict[str, str], row_idx: int, output_directory="output") -> None:
    try:
        benchmark_id = row['benchmarkID'].strip('"')
        output_data = load_benchmark_output_file(output_directory, benchmark_id)
        element_id_mappings = load_element_id_mappings(benchmark_id)
        demonstrations = output_data.setdefault('demonstrations', [])

        for demonstration_id in range(4):
            output_column_name = f'Output{demonstration_id + 1}'
            legacy_column_name = f'demonstration_table_{demonstration_id + 1}'
            table_text = row.get(output_column_name, '').strip()
            if not table_text:
                table_text = row.get(legacy_column_name, '').strip()
            if not table_text:
                continue

            while len(demonstrations) <= demonstration_id:
                demonstrations.append({})

            demonstrations[demonstration_id].update(
                process_demonstration_table(
                    table_text,
                    element_id_mapping=get_demonstration_element_id_mapping(
                        element_id_mappings,
                        demonstration_id,
                    ),
                )
            )

        save_benchmark_output_file(output_directory, benchmark_id, output_data)
        print(f"successful in {benchmark_id}")
    except Exception as e:
        print(e)


def write_output_to_file(input_file: str, output_directory="output", benchmark_id: Optional[str] = None) -> None:
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    matched_benchmark = False
    with open(input_file) as tsv:
        reader = csv.DictReader(tsv, dialect='excel-tab')

        for i, row in enumerate(reader):
            i += 2
            if not benchmark_matches(row.get('benchmarkID', ''), benchmark_id):
                continue
            matched_benchmark = True
            writer_output_helper(row, i, output_directory)

    if benchmark_id and not matched_benchmark:
        print(f'No row found for benchmarkID {benchmark_id}')


def main() -> None:
    parser = argparse.ArgumentParser(description='Generate new benchmark data.')
    parser.add_argument(
        '--benchmarkID',
        help='Only process the row in newQuery.tsv whose benchmarkID matches this value.',
    )
    args = parser.parse_args()

    script_directory = os.path.dirname(__file__)
    input_file = os.path.join(script_directory, 'newQuery.tsv')
    output_directory = os.path.join(script_directory, 'new_benchmarks')

    base_connection_uri, base_db_auth = get_base_connection()
    write_input_to_file(
        base_connection_uri,
        base_db_auth,
        input_file,
        output_directory=output_directory,
        benchmark_id=args.benchmarkID,
    )
    write_output_to_file(
        input_file,
        output_directory=output_directory,
        benchmark_id=args.benchmarkID,
    )


if __name__ == '__main__':
    main()
