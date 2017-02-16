#!/usr/bin/env python

import argparse
import sys
import pymorphy2
import csv
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument('--no-inflection', dest='inflection', action='store_false')
args = parser.parse_args()

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

if args.inflection:
    morph = pymorphy2.MorphAnalyzer()

def inflect(word):
    if not word or not args.inflection:
        return word

    suffix = word[-1] if word[-1] in {',', ')'} else ''
    word = word.rstrip(suffix)

    parses = morph.parse(word)

    if not parses:
        return word + suffix

    match = max(parses, key=lambda p: p.score + int('NOUN' in p.tag) * 10 + int('nomn' in p.tag) * 2)

    inflection = match.inflect({'gent'})

    return (inflection.word if inflection else word) + suffix

isas = defaultdict(set)

for row in csv.DictReader(sys.stdin, delimiter='\t', quoting=csv.QUOTE_NONE):
    if row['found'] == '0':
        continue

    row['genitive'] = '_'.join([inflect(word) for word in row['hypernym'].split('_')])

    isas[(row['hyponym'], row['genitive'])].add(row['hypernym'])

print('\t'.join(('hyponym', 'hypernym', 'genitive')))

for (hyponym, genitive), hypernyms in sorted(isas.items()):
    print('\t'.join((hyponym, ', '.join(sorted(hypernyms)), genitive)))
