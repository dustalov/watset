#!/usr/bin/env python

import argparse
import csv
import itertools
from concurrent.futures import ProcessPoolExecutor
import networkx as nx
from sklearn.metrics import confusion_matrix, precision_score, recall_score, f1_score
from collections import defaultdict
from scipy.stats import wilcoxon

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--significance', action='store_true')
parser.add_argument('--alpha', nargs='?', type=float, default=0.01)
parser.add_argument('path', nargs='+')
args = parser.parse_args()

METRICS = {metric: globals()[metric + '_score'] for metric in ('precision', 'recall', 'f1')}

def sanitize(str):
    return str.lower().replace(' ', '_')

def isas(path):
    G = nx.DiGraph()

    with open(path, newline='') as f:
        reader = csv.reader(f, delimiter='\t')

        for row in reader:
            if len(row) > 1 and row[0] and row[1]:
                G.add_edge(sanitize(row[0]), sanitize(row[1]))

    # Note that we store the sense inventory as an attribute of G.
    # TODO: nx.DiGraph subclass?
    G.senses = defaultdict(list)

    for node in G.nodes():
        G.senses[node.rsplit('#', 1)[0]].append(node)

    return G

with ProcessPoolExecutor() as executor:
    paths     = args.path + [args.gold]
    resources = {path: G for path, G in zip(paths, executor.map(isas, paths))}

gold = resources.pop(args.gold)

def has_sense_path(G, source, target):
    if source not in G.senses or target not in G.senses:
        return False

    for source_sense, target_sense in itertools.product(G.senses[source], G.senses[target]):
        if nx.has_path(G, source_sense, target_sense):
            return True

    return False

lexicon = gold.senses.keys() & set.union(*(set(G.senses.keys()) for G in resources.values()))

union = [pair for pair in {(word1.rsplit('#', 1)[0], word2.rsplit('#', 1)[0]) for word1, word2 in gold.edges()} | set.union(*(set(G.edges()) for G in resources.values())) if pair[0] in lexicon and pair[1] in lexicon]
true  = [int(has_sense_path(gold, *pair)) for pair in union]

index = defaultdict(list)

for pair in union:
    index[pair[0]].append(pair)

hyponyms = sorted(index)

def wordwise(G, pairs):
    word_true = [int(has_sense_path(gold, *pair)) for pair in pairs]
    word_pred = [int(has_sense_path(G, *pair))    for pair in pairs]

    return (word_true, word_pred)

def scores(G):
    if not args.significance:
        return

    labels = [wordwise(G, index[word]) for word in hyponyms]

    return {metric: [score(*true_pred) for true_pred in labels] for metric, score in METRICS.items()}

def evaluate(path):
    G = resources[path]

    pred = [int(has_sense_path(G, *pair)) for pair in union]

    tn, fp, fn, tp = confusion_matrix(true, pred).ravel()

    return {
        'tn':        tn,
        'fp':        fp,
        'fn':        fn,
        'tp':        tp,
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred),
        'scores':    scores(G)
    }

with ProcessPoolExecutor() as executor:
    results = {path: result for path, result in zip(resources, executor.map(evaluate, resources))}

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
        str(resources[path].size()),
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
