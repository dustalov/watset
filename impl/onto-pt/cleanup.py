#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
from collections import defaultdict
import itertools

clusters = {}
index = defaultdict(lambda: set())

with open('/home/dustalov/Work/watset/impl/onto-pt-clusters.txt') as f:
    id = 0

    for line in f:
        words = set(line.rstrip().split('\t'))

        clusters[id] = words

        for word in words:
            index[word].add(id)

        id += 1

def match(id):
    words = clusters[id]

    matches = {word: index[word] - {id} for word in words}

    for ids in itertools.product(*matches.values()):
        candidates = [clusters[sid] for sid in ids if sid in clusters]

        if candidates:
            yield candidates

# Remove the big ones.

queue = list(clusters.keys())

while queue:
    id    = queue.pop()
    words = clusters[id]

    for candidates in match(id):
        union = set.union(*candidates)

        if len(words & union) == len(union):
            del clusters[id]
            break

# Remove the small ones.

queue = list(clusters.keys())

while queue:
    id    = queue.pop()
    words = clusters[id]

    for candidates in match(id):
        for candidate in candidates:
            if len(candidate & words) >= len(words) and id in clusters:
                del clusters[id]
                break

# for id, words in clusters.items():
for id, words in enumerate(clusters.values()):
    print('\t'.join((str(id), str(len(words)), ', '.join(words))))

# import IPython; IPython.embed()
