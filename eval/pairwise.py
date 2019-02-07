#!/usr/bin/env python3

import argparse
import csv
import itertools
import pickle
from concurrent.futures import ProcessPoolExecutor, ThreadPoolExecutor
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score
from collections import defaultdict
from scipy.stats import wilcoxon

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--significance', action='store_true')
parser.add_argument('--dump', type=argparse.FileType('wb'))
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', nargs='+')
args = parser.parse_args()

METRICS = {metric: globals()[metric + '_score'] for metric in ('precision', 'recall', 'f1')}

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

index = defaultdict(list)

for pair in union:
    for word in pair:
        index[word].append(pair)

def wordwise(resource, word):
    word_true = [int(pair in resource) for pair in index[word]]
    word_pred = [int(pair in gold)     for pair in index[word]]

    return (word_true, word_pred)

def scores(resource):
    if not args.significance:
        return

    labels = [wordwise(resource, word) for word in lexicon]

    return {metric: [score(*true_pred) for true_pred in labels] for metric, score in METRICS.items()}

def evaluate(path):
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
        'scores':    scores(resources[path]),
        'pred':      pred if args.dump else None,
    }

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources.keys(), executor.map(evaluate, resources))}

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

if args.dump:
    dump = {'union': union, 'true': true, 'results': results}
    pickle.dump(dump, args.dump)

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
