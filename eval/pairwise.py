#!/usr/bin/env python

import argparse
import csv
import itertools
from concurrent.futures import ProcessPoolExecutor
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score
from collections import OrderedDict
from scipy.stats import wilcoxon

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--significance', nargs='?', choices=('false', 'precision', 'recall', 'f1'), default='false')
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', nargs='+')
args = parser.parse_args()

metric_score = None if args.significance == 'false' else globals()[args.significance + '_score']

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
    paths     = args.path + [args.gold]
    resources = {path: pairs for path, pairs in zip(paths, executor.map(synonyms, paths))}

gold = resources.pop(args.gold)

lexicon = words(gold) & set.union(*(words(pairs) for pairs in resources.values()))

union = [pair for pair in gold | set.union(*resources.values()) if pair[0] in lexicon and pair[1] in lexicon]
true  = [int(pair in gold) for pair in union]

lexicon = sorted(lexicon)

def wordwise(resource, word):
    pairs = [pair for pair in union if pair[0] == word or pair[1] == word]

    wtrue = [int(pair in resource) for pair in pairs]
    wpred = [int(pair in gold)     for pair in pairs]

    return (wtrue, wpred)

def evaluate(path):
    scores = OrderedDict((word, metric_score(*wordwise(resources[path], word))) for word in lexicon) if metric_score is not None else {}

    true = [int(pair in gold)            for pair in union]
    pred = [int(pair in resources[path]) for pair in union]

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
