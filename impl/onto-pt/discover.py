#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
from collections import defaultdict, Counter

parser = argparse.ArgumentParser()
parser.add_argument('--theta', nargs='?', type=float, default=.2)
args = vars(parser.parse_args())

unigrams = defaultdict(lambda: 0)
bigrams  = defaultdict(lambda: defaultdict(lambda: 0))

def prob(word1, word2):
    return float(bigrams[word1][word2]) / (unigrams[word1] + unigrams[word2] - bigrams[word1][word2])

for line in sys.stdin:
    words = list(set(line.rstrip().split('\t')))

    for i in range(len(words)):
        for j in range(i + 1, len(words)):
            word1, word2 = sorted((words[i], words[j]))

            unigrams[word1] += 1
            unigrams[word2] += 1

            bigrams[word1][word2] += 1
            bigrams[word2][word1] += 1

clusters = {}
index = defaultdict(lambda: set())

for id, word in enumerate(unigrams):
    clusters[id] = {word}
    clusters[id].update({neighbour for neighbour in bigrams[word] if prob(word, neighbour) > args['theta']})

    for word in clusters[id]:
        index[word].add(id)

def walk(queue = list(clusters.keys())):
    while queue:
        id    = queue.pop()
        words = clusters[id]
        yield (id, words)

def count(id):
    return Counter(cid for word in clusters[id] for cid in index[word] if cid != id and cid in clusters)

# Remove the exact duplicates.

def exact(id, words):
    counts = count(id)
    matches = {cid for cid in counts if words == clusters[cid]}

    for cid in matches:
        yield cid

for id, words in walk():
    for _ in exact(id, words):
        del clusters[id]
        break

# Remove the big ones.

def big(id):
    words, counts = clusters[id], count(id)

    matches = {word: {cid for cid in index[word] if cid != id and cid in clusters} for word in words}
    matches = {word: {cid for cid in values if cid not in counts or counts[cid] == len(clusters[cid])} for word, values in matches.items()}

    for ids in itertools.product(*matches.values()):
        candidates = [clusters[cid] for cid in ids if cid in clusters]

        if candidates:
            union = set.union(*candidates)
            yield union

for id, words in walk():
    for union in big(id):
        if len(words & union) == len(union):
            del clusters[id]
            break

# Remove the small ones.

def small(id, words):
    counts = count(id)
    matches = {cid for cid in counts if len(clusters[cid] & words) == len(words)}

    for cid in matches:
        yield cid

for id, words in walk():
    for _ in small(id, words):
        del clusters[id]
        break

for id, words in enumerate(clusters.values()):
    print('\t'.join((str(id), str(len(words)), ', '.join(words))))

