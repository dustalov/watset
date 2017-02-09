#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import csv
import gc
import sys
from collections import defaultdict
from sklearn.feature_extraction import DictVectorizer
from sklearn.metrics.pairwise import cosine_similarity as sim
from operator import itemgetter
import concurrent.futures

parser = argparse.ArgumentParser()
parser.add_argument('wsi', type=argparse.FileType('r'))
args = parser.parse_args()

wsi = defaultdict(lambda: dict())
D   = []

with args.wsi as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
    for row in reader:
        word, sid, _, words = row

        try:
            words = {k: float(v) for record in words.split('  ') for k, v in (record.rsplit(':', 1),)}
        except ValueError:
            print('Skipping misformatted string: %s.' % words, file=sys.stderr)
            continue

        wsi[word][int(sid)] = words
        D.append(words)

v = DictVectorizer().fit(D)

def emit(word):
    sneighbours = {}

    for sid, words in wsi[word].items():
        sense    = '%s#%d' % (word, sid)

        features = words.copy()
        features.update({word: 1.})

        vector = v.transform(features)

        sneighbours[sense] = {}

        for neighbour, weight in words.items():
            neighbours   = wsi[neighbour]
            candidates   = {nsid: sim(vector, v.transform(neighbours[nsid])).item(0) for nsid in neighbours}

            if not candidates:
                print('Missing candidates for "%s": "%s".' % (word, neighbour), file=sys.stderr)
                continue

            nsid, cosine = max(candidates.items(), key=itemgetter(1))

            if cosine > 0:
                nsense = '%s#%d' % (neighbour, nsid)
                sneighbours[sense][nsense] = weight
            else:
                print('Can not estimate the sense for "%s": "%s".' % (word, neighbour), file=sys.stderr)

    return sneighbours

with concurrent.futures.ProcessPoolExecutor() as executor:
    futures = (executor.submit(emit, word) for word in wsi)

    for i, future in enumerate(concurrent.futures.as_completed(futures)):
        sneighbours = future.result()

        for sense, neighbours in sneighbours.items():
            for nsense, weight in neighbours.items():
                print('%s\t%s\t%f' % (sense, nsense, weight))

        if (i + 1) % 1000 == 0:
            print('%d entries out of %d done.' % (i + 1, len(wsi)), file=sys.stderr)

if len(wsi) % 1000 != 0:
    print('%d entries out of %d done.' % (len(wsi), len(wsi)), file=sys.stderr)
