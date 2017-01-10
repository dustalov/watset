#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
from gensim.models.word2vec import Word2Vec
import csv

parser = argparse.ArgumentParser()
parser.add_argument('--sim', nargs='?', type=float, default=.3)
parser.add_argument('w2v')
args = vars(parser.parse_args())

w2v = Word2Vec.load_word2vec_format(args['w2v'], binary=True, unicode_errors='ignore')
w2v.init_sims(replace=True)
print('Using %d word2vec dimensions from "%s".' % (w2v.layer1_size, sys.argv[1]), file=sys.stderr)

reader = csv.reader(sys.stdin, delimiter='\t', quoting=csv.QUOTE_NONE)

for row in reader:
    word1, word2 = row[0], row[1]

    try:
        similarity = w2v.similarity(word1, word2)

        if similarity < 0:
            similarity = args['sim']
    except KeyError:
        similarity = args['sim']

    print('%s\t%s\t%f' % (word1, word2, similarity))
