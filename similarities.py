#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import sys
from gensim.models.word2vec import Word2Vec
import csv

w2v = Word2Vec.load_word2vec_format(sys.argv[1], binary=True, unicode_errors='ignore')
w2v.init_sims(replace=True)
print('Using %d word2vec dimensions from "%s".' % (w2v.layer1_size, sys.argv[1]), file=sys.stderr)

reader = csv.reader(sys.stdin, delimiter='\t', quoting=csv.QUOTE_NONE)

for row in reader:
    word1, word2 = row[0], row[1]

    try:
        similarity = w2v.similarity(word1, word2)
    except KeyError:
        similarity = 0.

    print('%s\t%s\t%f' % (word1, word2, similarity))
