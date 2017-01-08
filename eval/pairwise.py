#!/usr/bin/env python

import argparse
import csv
import sys
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from multiprocessing import Pool, cpu_count

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--lexicon', choices=('gold', 'joint'), default='joint')
parser.add_argument('--sorted', nargs='?', choices=('accuracy', 'precision', 'recall', 'f1'))
parser.add_argument('path', nargs='*')
args = vars(parser.parse_args())

def resource(path):
    pairs, lexicon = set(), set()

    with open(path) as f:
        reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)

        for row in reader:
            word1, word2 = sorted((row[0].lower(), row[1].lower()))

            pairs.add((word1, word2))
            lexicon.add(word1)
            lexicon.add(word2)

    return (path, pairs, lexicon)

def evaluate(path):
    pairs, _ = resources[path]
    return (path, len(pairs), scores(*tables(pairs)))

def tables(pairs):
    union = [pair for pair in (pairs | gold) if pair[0] in lexicon and pair[1] in lexicon]
    true  = [1 if pair in pairs else 0 for pair in union]
    pred  = [1 if pair in gold  else 0 for pair in union]
    return (true, pred)

def scores(true, pred):
    return {
        'accuracy':  accuracy_score(true, pred),
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred)
    }

_, gold, lexicon = resource(args['gold'])

resources, results = {}, []

with Pool(cpu_count()) as pool:
    for path, pairs, resource_lexicon in pool.imap_unordered(resource, args['path']):
        resources[path] = (pairs, resource_lexicon)

if args['lexicon'] == 'joint':
    lexicon &= set.union(*(resource_lexicon for _, resource_lexicon in resources.values()))

with Pool(cpu_count()) as pool:
    for row in pool.imap_unordered(evaluate, resources.keys()):
        results.append(row)

if args['sorted']:
    results = sorted(results, key=lambda item: item[2][args['sorted']], reverse=True)
else:
    index = {path: i for i, (path, _, _) in enumerate(results)}
    results = [results[index[path]] for path in args['path']]

writer = csv.writer(sys.stdout, dialect='excel-tab', lineterminator='\n')
writer.writerow(('path', 'pairs', 'accuracy', 'precision', 'recall', 'f1'))

for path, pairs, values in results:
    writer.writerow((
        path,
        pairs,
        values['accuracy'],
        values['precision'],
        values['recall'],
        values['f1']
    ))
