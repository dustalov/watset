#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import csv
from collections import defaultdict
import concurrent.futures
import operator
import networkx as nx
import sys
import pymorphy2
from functools import lru_cache

parser = argparse.ArgumentParser()
parser.add_argument('--freq', required=True, type=argparse.FileType('r'))
parser.add_argument('-n', nargs='?', type=int, default=300)
parser.add_argument('-k', nargs='?', type=int, default=3)
parser.add_argument('--skip', nargs='?', type=int, default=0)
parser.add_argument('--no-inflection', dest='inflection', action='store_false')
parser.add_argument('path', nargs='+')
args = parser.parse_args()

def sanitize(s):
    return s.lower().replace(' ', '_')

with args.freq as f:
    reader = csv.DictReader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
    freq = {sanitize(row['Lemma']): float(row['Freq']) for row in reader if row['PoS'] == 's'}

def top(data, n, skip=0, reverse=False):
    head = sorted(data.items(), key=operator.itemgetter(1), reverse=reverse)
    return [word for i, (word, _) in enumerate(head) if i < skip + n and i >= skip]

lexicon = top(freq, args.n, args.skip, reverse=True)

def isas(path):
    G = nx.DiGraph()

    with open(path, newline='') as f:
        reader = csv.reader(f, delimiter='\t')

        for row in reader:
            hyponym, hypernym = sanitize(row[0]), sanitize(row[1])

            if hyponym in freq and hyponym != hypernym:
                if not hyponym in G:
                    G.add_node(hyponym)

                if hypernym not in G[hyponym]:
                    G[hyponym][hypernym] = len(G[hyponym]) + 1

    return G

with concurrent.futures.ProcessPoolExecutor() as executor:
    resources = {path: G for path, G in zip(args.path, executor.map(isas, args.path))}

morph = pymorphy2.MorphAnalyzer()

@lru_cache(maxsize=None)
def inflect(word):
    if not word:
        return word

    suffix = word[-1] if word[-1] in {',', ')'} else ''
    word = word.rstrip(suffix)

    parses = morph.parse(word)

    if not parses:
        return word + suffix

    match = max(parses, key=lambda p: p.score + int('NOUN' in p.tag) * 10 + int('nomn' in p.tag) * 2)

    inflection = match.inflect({'gent'})

    return (inflection.word if inflection else word) + suffix

writer = csv.writer(sys.stdout, delimiter='\t')
writer.writerow(('resource', 'hyponym', 'found', 'hypernym', 'genitive', 'freq', 'n'))

for n, hyponym in enumerate(lexicon):
    for resource, G in resources.items():
        hypernyms = top(G[hyponym], args.k) if hyponym in G else []

        while len(hypernyms) < args.k:
            hypernyms.append(None)

        for hypernym in hypernyms:
            genitive = '_'.join([inflect(word) for word in hypernym.split('_')]) if args.inflection and hypernym else hypernym
            writer.writerow((resource, hyponym, int(not not hypernym), hypernym, genitive, freq[hyponym], n))
