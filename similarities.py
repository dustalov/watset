#!/usr/bin/env python3

import argparse
import csv
import sys
from signal import signal, SIGINT

from gensim.models import KeyedVectors

signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('--sim', type=float, default=.3)
parser.add_argument('w2v', type=argparse.FileType('rb'))
args = parser.parse_args()

w2v = KeyedVectors.load_word2vec_format(args.w2v, binary=True, unicode_errors='ignore')
w2v.init_sims(replace=True)
print('Using %d word2vec dimensions from "%s".' % (w2v.vector_size, args.w2v.name), file=sys.stderr)

reader = csv.reader(sys.stdin, delimiter='\t', quoting=csv.QUOTE_NONE)

for row in reader:
    word1, word2 = row[0], row[1]

    try:
        similarity = w2v.similarity(word1, word2)

        if similarity < 0:
            similarity = args.sim
    except KeyError:
        similarity = args.sim

    print('%s\t%s\t%f' % (word1, word2, similarity))
