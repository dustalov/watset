#!/usr/bin/env python

import argparse
import csv
from collections import OrderedDict, defaultdict
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
parser.add_argument('--significance', nargs='?', choices=('false', 'precision', 'recall', 'f1'), default='false')
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', nargs='+', type=argparse.FileType('r'))
args = parser.parse_args()

metric_score = None if args.significance == 'false' else globals()[args.significance + '_score']

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

    true = [int(pair[1] is None or gold[pair]) for pair in pairs]
    pred = [int(pair[1] is not None)           for pair in pairs]

    return (true, pred)

def evaluate(path):
    scores = OrderedDict((word, metric_score(*wordwise(resources[path], word))) for word in lexicon) if metric_score is not None else {}

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
        'scores':    scores
    }

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources.keys(), executor.map(evaluate, resources.keys()))}

if metric_score is not None:
    results = OrderedDict(item for item in sorted(results.items(), key=lambda item: item[1][args.significance], reverse=True))

    def pairwise(iterable):
        a, b = itertools.tee(iterable)
        next(b, None)
        return zip(a, b)

    for (x_path, x_result), (_, y_result) in pairwise(results.items()):
        x, y = list(x_result['scores'].values()), list(y_result['scores'].values())
        results[x_path]['sign'] = int(wilcoxon(x, y).pvalue < args.alpha)

print('\t'.join(('path', 'pairs', 'tn', 'fp', 'fn', 'tp', 'precision', 'recall', 'f1', 'sign')))

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
        str(values.get('sign', int(False)))
    )))
