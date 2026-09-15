import csv
import os
import json
import configparser
from collections import defaultdict

from neo4j import GraphDatabase, basic_auth
from neo4j.graph import Node, Relationship

# PUT YOUR CONNECTION INFORMATION HERE
config_parser = configparser.RawConfigParser()
config_parser.read(os.path.join(os.path.dirname(__file__), 'database-config.txt'))

BASE_CONNECTION_URI = config_parser.get('database', 'BASE').strip()
BASE_DB_AUTH = basic_auth("neo4j", config_parser.get('database', 'BASEPASS').strip())
'''
Overall Description

Reads in a tsv file and for each of the benchmarks in the tsv file it will create an input, output, and node/edge labels file.

Input and output are formatted as a json string with top level keys of 'nodes' and 'edges' each of which correspond to an array of nodes or edges respectively.
See the functions below to see which key/values are included in each of those representations. 

Also writes another file for all of the labels that exist for nodes and edges, this is useful information for eusolver
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
        self.driver = GraphDatabase.driver(connection_uri, auth=db_auth)
        self.database_name = database_name
        self.input_graph = None

    def exec_query(self, query: str) -> tuple:
        records, summary, keys = self.driver.execute_query(query_=query, database_=self.database_name)
        return records, summary, keys

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
    def create_node_representation(self, n: Node) -> dict:
        node = {
            'element_id': n.element_id.split(":")[2],
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
            'element_id': r.element_id.split(":")[2],
            'start': r.start_node.element_id.split(":")[2],
            'end': r.end_node.element_id.split(":")[2],
        }

        for key in r.keys():
            value = r[key]

            if isinstance(value, list):
                value = [x.replace('"', '') for x in value]

            edge[key] = value

        return edge

def writer_input_helper(base_url: str, base_auth, row: list[str], row_idx: int, output_directory="output") -> None:

    try:
        benchmarkID, create_query_1, create_query_2, create_query_3, create_query_4 = row[0].strip('"'), row[1].strip('"'), row[2].strip('"'), row[3].strip('"'), row[4].strip('"')
        queries = {0: create_query_1, 1: create_query_2, 2: create_query_3, 3: create_query_4}
        
        datas = []
        for demonstrationID in range(4):
            if queries[demonstrationID]!="":
                datas.append({"inputGraph": None, "mapping1":None, "mapping2":None, "mapping3":[]})
                db = GraphDB(base_url, base_auth, "experiment"+str(benchmarkID)+"Demonstration"+str(demonstrationID))
                try:
                    db.driver.execute_query("CREATE DATABASE experiment"+str(benchmarkID)+"Demonstration"+str(demonstrationID))
                except:
                    print("Database already there")
                db.clear_graph()
                # TODO: More than one create query in different databases
                db.exec_query(queries[demonstrationID])

                # query our start graph and execute the query to get the output
                input_data = db.get_full_graph()
                datas[demonstrationID]["inputGraph"] = input_data
        
        with open(f'{output_directory}/benchmark{benchmarkID}.json', 'w', encoding='utf-8') as f:
            demonstrations = []
            for demonstrationID in range(13):
                if queries[demonstrationID] != "":
                    demonstrations.append({'inputGraph': datas[demonstrationID]["inputGraph"]
                                            'correspondence': datas[demonstrationID]["correspondence"]})
            json.dump({'demonstrations':demonstrations}, f, ensure_ascii=False, indent=4)
        print(f"successful in {row_idx}")
    except Exception as e:
        print(e)


def write_input_to_file(base_url: str, base_auth, input_file: str,
                               output_directory="output") -> None:
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    with open(input_file) as tsv:
        reader = csv.reader(tsv, dialect='excel-tab')
        next(reader)

        for i, row in enumerate(reader):
            i += 2
            writer_helper(base_url, base_auth, row, i)


if __name__ == '__main__':
    write_input_to_file(BASE_CONNECTION_URI, BASE_DB_AUTH, os.path.join(os.path.dirname(__file__), 'queries.tsv'),
                               output_directory=os.path.join(os.path.dirname(__file__), 'output'))


# (2)writer_output_helper function: it read from column demonstration_table_1 to demonstration_table_4, content in the column is a table of expressions, which is represented as a list of list,  each expression may look like n1.name or a math expression like max(n2.age, n3.age), please process each expression to dictionary according to this rule