#!/usr/bin/env python3

import argparse
import pickle
import sys
from concurrent.futures import ProcessPoolExecutor, as_completed
from itertools import combinations

from statsmodels.stats.contingency_tables import mcnemar

parser = argparse.ArgumentParser()
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', type=argparse.FileType('rb'))
args = parser.parse_args()

dump = pickle.load(args.path)

results = dump['results']


def evaluate(path1, path2):
    y_pred_1, y_pred_2 = results[path1]['pred'], results[path2]['pred']

    table = [[0, 0], [0, 0]]
    table[0][1] = sum(1 if y_pred_1[i] == 1 and y_pred_2[i] == 0 else 0 for i in range(len(y_pred_1)))
    table[1][0] = sum(1 if y_pred_1[i] == 0 and y_pred_2[i] == 1 else 0 for i in range(len(y_pred_1)))

    return (path1, path2), mcnemar(table).pvalue


with ProcessPoolExecutor() as executor:
    pairs = list(combinations(results, 2))
    futures = (executor.submit(evaluate, *pair) for pair in pairs)

    for i, future in enumerate(as_completed(futures)):
        (path1, path2), pvalue = future.result()
        print('%s\t%s\t%.6f' % (path1, path2, pvalue))

        if (i + 1) % 100 == 0:
            print('%d pairs out of %d done.' % (i + 1, len(pairs)), file=sys.stderr)

if len(pairs) % 100 != 0:
    print('%d pairs out of %d done.' % (i + 1, len(pairs)), file=sys.stderr)
