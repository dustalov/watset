#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys

parser = argparse.ArgumentParser()
parser.add_argument('lexicon')
args = vars(parser.parse_args())

with open(args['lexicon']) as f:
    lexicon = {word.lower(): i for i, word in enumerate(f.read().splitlines())}

for row in sys.stdin:
    _, _, words = row.rstrip().split('\t', 3)

    words = [word.lower() for word in words.split(', ')]
    words = [str(lexicon[word]) for word in words if word in lexicon]

    if len(words) > 0:
        print(' '.join(words))
