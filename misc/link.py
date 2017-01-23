#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import csv
import sys
import itertools
from collections import defaultdict, Counter
from math import log
from sklearn.feature_extraction import DictVectorizer
from sklearn.metrics.pairwise import cosine_similarity as sim
from operator import itemgetter
from multiprocessing import Pool, cpu_count

parser = argparse.ArgumentParser()
parser.add_argument('--synsets', required=True)
parser.add_argument('--isas', required=True)
parser.add_argument('-k', nargs='?', type=int, default=6)
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

isas = defaultdict(lambda: set())

with open(args['isas']) as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
    for hyponym, hypernym in reader:
        if hyponym in lexicon and hypernym in lexicon:
            isas[hyponym].add(hypernym)

idf, D = defaultdict(lambda: 0), .0

for words in synsets.values():
    hypernyms = [isas[word] for word in words if word in isas]

    if not hypernyms:
        continue

    for hypernym in set.union(*hypernyms):
        idf[hypernym] += 1

    D += 1

idf = {hypernym: log(D / df) for hypernym, df in idf.items()}

def tf(w, words):
    return float(Counter(words)[w])

def tfidf(w, words):
    return tf(w, words) * idf.get(w, 1.)

hctx = {}

for id, words in synsets.items():
    hypernyms = list(itertools.chain(*(isas[word] for word in words if word in isas)))

    if not hypernyms:
        continue

    hctx[id] = {word: tfidf(word, hypernyms) for word in hypernyms}

v = DictVectorizer().fit(hctx.values())

def emit(id):
    if not id in hctx:
        return (id, {})

    hypernyms, vector, hsenses = hctx[id], v.transform(hctx[id]), {}

    for hypernym in hypernyms:
        candidates = {hid: synsets[hid] for hid in index[hypernym]}

        if not candidates:
            continue

        candidates = {hid: {word: tfidf(word, words) for word in words} for hid, words in candidates.items()}
        candidates = {hid: sim(vector, v.transform(words)) for hid, words in candidates.items()}

        hid, cosine = max(candidates.items(), key=itemgetter(1))

        if cosine > 0:
            hsenses[(hypernym, hid)] = cosine

    hsenses = dict(dict(sorted(hsenses.items(), key=itemgetter(1), reverse=True)[:args['k']]).keys())

    return (id, hsenses)

i = 0

with Pool(cpu_count()) as pool:
    for id, hsenses in pool.imap_unordered(emit, synsets):
        i += 1

        senses = [(word, index[word][id]) for word in synsets[id]]
        senses_str = ', '.join(('%s#%d' % sense for sense in senses))

        isas = [(word, index[word][hid]) for word, hid in hsenses.items()]
        isas_str = ', '.join(('%s#%d' % sense for sense in isas))

        print('\t'.join((str(id), str(len(synsets[id])), senses_str, str(len(isas)), isas_str)))

        if i % 1000 == 0:
            print('%d entries out of %d done.' % (i, len(hctx)), file=sys.stderr, flush=True)

if len(hctx) % 1000 != 0:
    print('%d entries out of %d done.' % (len(hctx), len(hctx)), file=sys.stderr, flush=True)
