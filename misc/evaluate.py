#!/usr/bin/env python

import argparse
import csv
from concurrent.futures import ProcessPoolExecutor
import networkx as nx
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--lexicon', choices=('gold', 'joint'), default='joint')
parser.add_argument('path', nargs='+')
args = vars(parser.parse_args())

def sanitize(str):
    return str.lower().replace(' ', '_')

def isas(path):
    G = nx.DiGraph()

    with open(path, newline='') as f:
        reader = csv.reader(f, delimiter='\t')

        for hyponym, hypernym in reader:
            G.add_edge(sanitize(hyponym), sanitize(hypernym))

    return G

with ProcessPoolExecutor() as executor:
    paths     = args['path'] + [args['gold']]
    resources = {path: G for path, G in zip(paths, executor.map(isas, paths))}

gold = resources.pop(args['gold'])

lexicon = set(gold.nodes())

if args['lexicon'] == 'joint':
    lexicon &= set.union(*(set(G.nodes()) for G in resources.values()))

def tables(G):
    union = [pair for pair in set(gold.edges()) | set(G.edges()) if pair[0] in lexicon and pair[1] in lexicon]

    true  = [int(pair[0] in gold and pair[1] in gold and nx.has_path(gold, *pair)) for pair in union]
    pred  = [int(pair[0] in G    and pair[1] in G    and nx.has_path(G,    *pair)) for pair in union]

    return (true, pred)

def scores(true, pred):
    return {
        'accuracy':  accuracy_score(true, pred),
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred)
    }

def evaluate(path):
    return scores(*tables(resources[path]))

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources.keys(), executor.map(evaluate, resources.keys()))}

print('\t'.join(('path', 'pairs', 'accuracy', 'precision', 'recall', 'f1')))

for path, values in results.items():
    print('\t'.join((
        path,
        str(resources[path].size()),
        str(values['accuracy']),
        str(values['precision']),
        str(values['recall']),
        str(values['f1'])
    )))
