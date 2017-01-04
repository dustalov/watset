#!/usr/bin/env python

import argparse
import csv
import sys
from sklearn.metrics import accuracy_score, roc_auc_score, precision_score, recall_score, f1_score

parser = argparse.ArgumentParser()
parser.add_argument('--gold', required=True)
parser.add_argument('--lexicon', choices=['gold', 'joint'], default='gold')
parser.add_argument('path', nargs='*')
args = vars(parser.parse_args())

def resource(filename):
    pairs, lexicon = set(), set()

    with open(filename) as f:
        reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)

        for row in reader:
            word1, word2 = sorted((row[0].lower(), row[1].lower()))

            pairs.add((word1, word2))
            lexicon.add(word1)
            lexicon.add(word2)

    return (pairs, lexicon)

def tables(pairs):
    union = [pair for pair in (pairs | gold) if pair[0] in lexicon and pair[1] in lexicon]
    true  = [1 if pair in pairs else 0 for pair in union]
    pred  = [1 if pair in gold  else 0 for pair in union]
    return (true, pred)

def scores(true, pred):
    return {
        'accuracy':  accuracy_score(true, pred),
        'roc_auc':   roc_auc_score(true, pred),
        'precision': precision_score(true, pred),
        'recall':    recall_score(true, pred),
        'f1':        f1_score(true, pred)
    }

gold, gold_lexicon = resource(args['gold'])

resources = {path: resource(path) for path in args['path']}

lexicon = gold_lexicon

if args['lexicon'] == 'joint':
    for _, resource_lexicon in resources.values():
        lexicon = lexicon & resource_lexicon

results = [(path, scores(*tables(pairs))) for path, (pairs, _) in resources.items()]
results = sorted(results, key=lambda item: item[1]['f1'], reverse=True)

writer = csv.writer(sys.stdout, dialect='excel-tab', lineterminator='\n')
writer.writerow(('path', 'accuracy', 'roc_auc', 'precision', 'recall', 'f1'))

for path, values in results:
    writer.writerow((
        path,
        values['accuracy'],
        values['roc_auc'],
        values['precision'],
        values['recall'],
        values['f1']
    ))
