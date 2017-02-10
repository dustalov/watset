#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
import csv

parser = argparse.ArgumentParser()
parser.add_argument('lexicon', type=argparse.FileType('r'))
parser.add_argument('-1', action='store_true', dest='first')
args = parser.parse_args()

with args.lexicon as f:
    lexicon = {word for word in f.read().splitlines()}

for row in csv.reader(sys.stdin, delimiter='\t'):
    if row[0] in lexicon and (args.first or row[1] in lexicon):
        print('\t'.join((row[0], row[1])))
