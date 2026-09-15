#!/usr/bin/env python3

"""Build reusable element_id/id mappings from benchmark input graphs."""

import argparse
import json
import os
import re


SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
DEFAULT_INPUT = os.path.join(
    os.path.dirname(SCRIPT_DIRECTORY),
    'new_benchmarks',
    'benchmark100.json',
)
DEFAULT_OUTPUT = os.path.join(
    SCRIPT_DIRECTORY,
    'benchmark100_element_id_mappings.json',
)


def build_entity_mappings(entities, entity_type, demonstration_id):
    element_id_to_id = {}
    id_to_element_id = {}

    for entity_index, entity in enumerate(entities):
        if 'element_id' not in entity or 'id' not in entity:
            raise ValueError(
                'Demonstration {} {} {} must contain element_id and id'.format(
                    demonstration_id,
                    entity_type,
                    entity_index,
                )
            )

        element_id = str(entity['element_id'])
        entity_id = entity['id']
        entity_id_key = str(entity_id)

        if element_id in element_id_to_id:
            raise ValueError(
                'Duplicate {} element_id {!r} in demonstration {}'.format(
                    entity_type,
                    element_id,
                    demonstration_id,
                )
            )
        if entity_id_key in id_to_element_id:
            raise ValueError(
                'Duplicate {} id {!r} in demonstration {}'.format(
                    entity_type,
                    entity_id,
                    demonstration_id,
                )
            )

        element_id_to_id[element_id] = entity_id
        id_to_element_id[entity_id_key] = element_id

    return {
        'element_id_to_id': element_id_to_id,
        'id_to_element_id': id_to_element_id,
    }


def get_benchmark_id(input_file):
    match = re.search(r'benchmark(\d+)(?:_inputGraph)?\.json$', os.path.basename(input_file))
    return match.group(1) if match else None


def get_demonstrations(benchmark_data):
    if isinstance(benchmark_data, dict):
        demonstrations = benchmark_data.get('demonstrations')
        if isinstance(demonstrations, list):
            return demonstrations
    if isinstance(benchmark_data, list):
        return benchmark_data
    raise ValueError('Benchmark input must contain a list of demonstrations')


def build_mappings(input_file):
    with open(input_file, encoding='utf-8') as input_handle:
        benchmark_data = json.load(input_handle)

    demonstrations = []
    for demonstration_id, demonstration in enumerate(get_demonstrations(benchmark_data)):
        input_graph = demonstration.get('inputGraph')
        if not isinstance(input_graph, dict):
            raise ValueError(
                'Demonstration {} does not contain an inputGraph object'.format(
                    demonstration_id
                )
            )

        demonstrations.append({
            'demonstration_id': demonstration_id,
            'nodes': build_entity_mappings(
                input_graph.get('nodes', []),
                'node',
                demonstration_id,
            ),
            'edges': build_entity_mappings(
                input_graph.get('edges', []),
                'edge',
                demonstration_id,
            ),
        })

    return {
        'benchmark_id': get_benchmark_id(input_file),
        'source_file': os.path.basename(input_file),
        'demonstrations': demonstrations,
    }


def parse_args():
    parser = argparse.ArgumentParser(
        description='Create element_id/id mappings for a benchmark input graph.'
    )
    parser.add_argument(
        'input_file',
        nargs='?',
        default=DEFAULT_INPUT,
        help='Input benchmark JSON (default: benchmark100.json)',
    )
    parser.add_argument(
        '-o',
        '--output',
        default=DEFAULT_OUTPUT,
        help='Destination mapping JSON',
    )
    return parser.parse_args()


def main():
    args = parse_args()
    input_file = os.path.abspath(args.input_file)
    output_file = os.path.abspath(args.output)

    mappings = build_mappings(input_file)
    output_directory = os.path.dirname(output_file)
    if not os.path.isdir(output_directory):
        os.makedirs(output_directory)

    with open(output_file, 'w', encoding='utf-8') as output_handle:
        json.dump(mappings, output_handle, ensure_ascii=False, indent=4)
        output_handle.write('\n')

    print('Saved mappings to {}'.format(output_file))


if __name__ == '__main__':
    main()
