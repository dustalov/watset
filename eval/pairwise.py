#!/usr/bin/env python

import argparse
import csv
from concurrent.futures import ProcessPoolExecutor
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--lexicon', choices=('gold', 'joint'), default='joint')
parser.add_argument('path', nargs='+')
args = vars(parser.parse_args())

def synonyms(path):
    pairs = set()

    with open(path) as f:
        reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)

        for row in reader:
            word1, word2 = sorted((row[0].lower(), row[1].lower()))

            pairs.add((word1, word2))

    return pairs

def words(pairs):
    return {w for w, _ in pairs} | {w for _, w in pairs}

with ProcessPoolExecutor() as executor:
    paths     = args['path'] + [args['gold']]
    resources = {path: pairs for path, pairs in zip(paths, executor.map(synonyms, paths))}

gold = resources.pop(args['gold'])

lexicon = words(gold)

if args['lexicon'] == 'joint':
    lexicon &= set.union(*(words(pairs) for pairs in resources.values()))

union = [pair for pair in gold | set.union(*resources.values()) if pair[0] in lexicon and pair[1] in lexicon]

def tables(pairs):
    true = [1 if pair in pairs else 0 for pair in union]
    pred = [1 if pair in gold  else 0 for pair in union]
    return (true, pred)

def scores(true, pred):
    tn, fp, fn, tp = confusion_matrix(true, pred).ravel()

    return {
        'samples':   len(pred),
        'tn':        tn,
        'fp':        fp,
        'fn':        fn,
        'tp':        tp,
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred)
    }

def evaluate(path):
    return scores(*tables(resources[path]))

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources.keys(), executor.map(evaluate, resources.keys()))}

print('\t'.join(('path', 'pairs', 'tn', 'fp', 'fn', 'tp', 'precision', 'recall', 'f1')))

for path, values in results.items():
    resource = resources[path]
    print('\t'.join((
        path,
        str(len(resource)),
        str(values['tn']),
        str(values['fp']),
        str(values['fn']),
        str(values['tp']),
        str(values['precision']),
        str(values['recall']),
        str(values['f1']),
    )))
