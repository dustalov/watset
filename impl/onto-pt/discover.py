#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
from collections import defaultdict

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

for word in unigrams:
    cluster = {word}

    cluster.update({neighbour for neighbour in bigrams[word] if prob(word, neighbour) > args['theta']})

    print('\t'.join(cluster))
