#!/usr/bin/env python

import argparse
import csv
from collections import defaultdict
from concurrent.futures import ProcessPoolExecutor
import operator
import sys
import itertools
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score
from scipy.stats import wilcoxon

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('--sample', required=True, type=argparse.FileType('r'))
parser.add_argument('--significance', action='store_true')
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', nargs='+', type=argparse.FileType('r'))
args = parser.parse_args()

METRICS = {metric: globals()[metric + '_score'] for metric in ('precision', 'recall', 'f1')}

gold = defaultdict(lambda: False)

for path in args.path:
    with path as f:
        for row in csv.DictReader(f, delimiter='\t', quoting=csv.QUOTE_NONE):
            if not row['INPUT:hypernym'] or not row['OUTPUT:judgement']:
                continue

            hyponym = row['INPUT:hyponym']

            for hypernym in row['INPUT:hypernym'].split(', '):
                assert (hyponym, hypernym) not in gold, (hyponym, hypernym)

                gold[(hyponym, hypernym)] = (row['OUTPUT:judgement'].lower() == 'true')

resources = defaultdict(list)

with args.sample as f:
    for row in csv.DictReader(f, delimiter='\t', quoting=csv.QUOTE_NONE):
        hyponym, hypernym = row['hyponym'], row['hypernym'] if row['hypernym'] else None

        assert hypernym is None or (hyponym, hypernym) in gold, (hyponym, hypernym)

        resources[row['path']].append((hyponym, hypernym))

lexicon = sorted({hyponym for pairs in resources.values() for hyponym, _ in pairs})

def wordwise(resource, word):
    pairs = [pair for pair in resource if pair[0] == word]

    word_true = [int(pair[1] is None or gold[pair]) for pair in pairs]
    word_pred = [int(pair[1] is not None)           for pair in pairs]

    return (word_true, word_pred)

def scores(resource):
    if not args.significance:
        return

    labels = [wordwise(resource, word) for word in lexicon]

    return {metric: [score(*true_pred) for true_pred in labels] for metric, score in METRICS.items()}

def evaluate(path):
    true = [int(pair[1] is None or gold[pair]) for pair in resources[path]]
    pred = [int(pair[1] is not None)           for pair in resources[path]]

    tn, fp, fn, tp = confusion_matrix(true, pred).ravel()

    return {
        'tn':        tn,
        'fp':        fp,
        'fn':        fn,
        'tp':        tp,
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred),
        'scores':    scores(resources[path])
    }

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources.keys(), executor.map(evaluate, resources.keys()))}

def pairwise(iterable):
    a, b = itertools.tee(iterable)
    next(b, None)
    return zip(a, b)

def significance(metric):
    if not args.significance:
        return {}

    desc, rank = sorted(results.items(), key=lambda item: item[1][metric], reverse=True), 1

    ranks = {}

    for (path1, results1), (path2, results2) in pairwise(desc):
        x, y = list(results1['scores'][metric]), list(results2['scores'][metric])

        ranks[path1] = rank

        rank += int(wilcoxon(x, y).pvalue < args.alpha)

        ranks[path2] = rank

    return ranks

with ProcessPoolExecutor() as executor:
    ranks = {metric: result for metric, result in zip(METRICS, executor.map(significance, METRICS))}

print('\t'.join(('path', 'pairs', 'tn', 'fp', 'fn', 'tp', 'precision', 'recall', 'f1', 'precision_rank', 'recall_rank', 'f1_rank')))

for path, values in results.items():
    print('\t'.join((
        path,
        str(len(resources[path])),
        str(values['tn']),
        str(values['fp']),
        str(values['fn']),
        str(values['tp']),
        str(values['precision']),
        str(values['recall']),
        str(values['f1']),
        str(ranks['precision'].get(path, 0)),
        str(ranks['recall'   ].get(path, 0)),
        str(ranks['f1'       ].get(path, 0))
    )))
