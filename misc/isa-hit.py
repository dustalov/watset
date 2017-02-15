#!/usr/bin/env python

import argparse
import csv
from collections import defaultdict
import concurrent.futures
import operator
import sys
import pymorphy2

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

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

morph = pymorphy2.MorphAnalyzer()

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

def emit(path):
    isas = defaultdict(lambda: dict())

    with open(path, newline='') as f:
        reader = csv.reader(f, delimiter='\t')

        for row in reader:
            hyponym, hypernym = sanitize(row[0]), sanitize(row[1])

            if hyponym in freq and hyponym != hypernym:
                if hypernym not in isas[hyponym]:
                    isas[hyponym][hypernym] = len(isas[hyponym]) + 1

    rows = []

    for n, hyponym in enumerate(lexicon):
        hypernyms = top(isas[hyponym], args.k) if hyponym in isas else []

        while len(hypernyms) < args.k:
            hypernyms.append(None)

        for hypernym in hypernyms:
            genitive = '_'.join([inflect(word) for word in hypernym.split('_')]) if args.inflection and hypernym else hypernym
            rows.append((path, hyponym, int(not not hypernym), hypernym, genitive, freq[hyponym], n))

    return rows

writer = csv.writer(sys.stdout, delimiter='\t')
writer.writerow(('path', 'hyponym', 'found', 'hypernym', 'genitive', 'freq', 'n'))

with concurrent.futures.ProcessPoolExecutor() as executor:
    futures = (executor.submit(emit, path) for path in args.path)

    for future in concurrent.futures.as_completed(futures):
        for row in future.result():
            writer.writerow(row)
