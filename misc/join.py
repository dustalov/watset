#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import csv
import sys
from collections import defaultdict

parser = argparse.ArgumentParser()
parser.add_argument('--synsets', required=True)
parser.add_argument('--links', required=True)
args = vars(parser.parse_args())

synsets, index, lexicon = {}, defaultdict(lambda: list()), set()

with open(args['synsets']) as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)

    for row in reader:
        synsets[int(row[0])] = [word for word in row[2].split(', ') if word]

        for word in synsets[int(row[0])]:
            index[word].append(int(row[0]))

        lexicon.update(synsets[int(row[0])])

index = {word: {id: i + 1 for i, id in enumerate(ids)} for word, ids in index.items()}

links = {}

with open(args['links']) as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)

    for row in reader:
        hsenses = [tuple(sense_hid.split('#', 2)) for sense_hid in row[1].split(', ') if sense_hid]

        links[int(row[0])] = [(hypernym, int(hid)) for hypernym, hid in hsenses]

for id, synset in synsets.items():
    senses = [(word, index[word][id]) for word in synset]
    senses_str = ', '.join(('%s#%d' % sense for sense in senses))

    isas = links.get(id, [])
    isas = [(word, index[word][hid]) for word, hid in isas]
    isas_str = ', '.join(('%s#%d' % sense for sense in isas))

    print('\t'.join((str(id), str(len(synset)), senses_str, str(len(isas)), isas_str)))

# import IPython; IPython.embed()
