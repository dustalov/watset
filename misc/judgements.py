#!/usr/bin/env python

import argparse
import csv
from collections import OrderedDict, defaultdict
import concurrent.futures
import operator
import sys
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('--sample', required=True, type=argparse.FileType('r'))
parser.add_argument('path', nargs='+', type=argparse.FileType('r'))
args = parser.parse_args()

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

# import IPython; IPython.embed()

results = defaultdict(list)

with args.sample as f:
    for row in csv.DictReader(f, delimiter='\t', quoting=csv.QUOTE_NONE):
        hyponym, hypernym = row['hyponym'], row['hypernym'] if row['hypernym'] else None

        assert hypernym is None or (hyponym, hypernym) in gold, (hyponym, hypernym)

        results[row['path']].append((hyponym, hypernym))

writer = csv.writer(sys.stdout, delimiter='\t', lineterminator='\n')
writer.writerow(('path', 'pairs', 'tn', 'fp', 'fn', 'tp', 'precision', 'recall', 'f1'))

for path, pairs in results.items():
    true = [pair[1] is None or gold[pair] for pair in pairs]
    pred = [pair[1] is not None           for pair in pairs]

    writer.writerow((path, len(pairs), *confusion_matrix(true, pred).ravel(), precision_score(true, pred), recall_score(true, pred), f1_score(true, pred)))
