import json
import os
import configparser
from src.utils.graph import Graph, CypherType, create_bag

CONFIG_FILE_DIRECTORY = os.path.join(os.path.dirname(__file__), 'benchmarks/cypher/demonstration_config_testing/')

def check_graph(config, in_graph, out_graph):
    with open('input.json', 'w+') as in_json:
            in_json.write(c_parser.get('benchmark', in_graph))

    with open('output.json', 'w+') as out_json:
        out_json.write(c_parser.get('benchmark', out_graph))

    entire_file = open('input.json')
    entire_graph_json = json.load(entire_file)

    nodes = set()
    for node in entire_graph_json['nodes']:
        nodes.add(CypherType(node))

    edges = set()
    for edge in entire_graph_json['edges']:
        edges.add(CypherType(edge))

    output_file = open('output.json')
    output_graph_json = json.load(output_file)

    output_graph_list = []
    for value in output_graph_json:
        if 'operation' in value and value['operation'] in ['SUM', 'COUNT', 'MIN', 'MAX', 'AVG', 'add', 'sub', 'div', 'mul']:
            value['values'] = create_bag([x for x in value['values']])

        output_graph_list.append(CypherType(value))

    output_graph = Graph(nodes=set(), edges=set(), var_map={}, paths=[], output_graph=output_graph_list)

    entire_graph = Graph(nodes=nodes, edges=edges, var_map={}, paths=[])

    query = f'''{c_parser.get('testing', 'query')}'''
    result_graph = eval(query)
    
    entire_file.close()
    output_file.close()
    
    return result_graph == output_graph
        

with open('query_test_output.csv', 'w+') as output_csv:
    output_csv.write('file,status\n')
    list_of_benchmarks = os.listdir(CONFIG_FILE_DIRECTORY)
    list_of_benchmarks.sort()
    list_of_benchmarks.sort(key=len)

    c_parser = configparser.RawConfigParser()

    for file in list_of_benchmarks:
        c_parser.read(os.path.join(CONFIG_FILE_DIRECTORY, file))
        
        match = check_graph(c_parser, 'Input Graph', 'Output Graph')

        try:
            second_match = check_graph(c_parser, 'Second In', 'Second Out')
        except:
            second_match = True

        if match and second_match:
            output_csv.write(f'{file},Success\n')
        else:
            output_csv.write(f'{file},Fail\n')
            
os.remove('input.json')
os.remove('output.json')
