#!/usr/bin/env python

import argparse
import sys

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('lexicon', type=argparse.FileType('r'))
args = parser.parse_args()

with args.lexicon as f:
    lexicon = {word.lower(): i for i, word in enumerate(f.read().splitlines())}

for row in sys.stdin:
    _, _, words = row.rstrip().split('\t', 3)

    words = [word.lower() for word in words.split(', ')]
    words = [str(lexicon[word]) for word in words if word in lexicon]

    if len(words) > 0:
        print(' '.join(words))
