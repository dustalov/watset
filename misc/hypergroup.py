#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import csv
import sys
import itertools

FIELDS = ('resource', 'hyponym', 'found', 'hypernym', 'genitive', 'freq', 'n')

KEY = lambda x: (x['hyponym'], x['genitive'])

writer = csv.DictWriter(sys.stdout, delimiter='\t', fieldnames=FIELDS)
writer.writeheader()

reader = csv.DictReader(sys.stdin, delimiter='\t', quoting=csv.QUOTE_NONE)

rows = []

for row in reader:
    if row['found'] == '0':
        writer.writerow(row)
    else:
        rows.append(row)

for _, group in itertools.groupby(sorted(rows, key=KEY), key=KEY):
    group = list(group)
    hypernyms = sorted({row['hypernym'] for row in group})
    group[0]['hypernym'] = ', '.join(hypernyms)
    writer.writerow(group[0])
