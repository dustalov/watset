#!/usr/bin/env python

import csv
import sys

synsets, index = {}, {}

with open('03-cw.txt') as f:
    reader = csv.reader(f, delimiter='\t', quoting=csv.QUOTE_NONE)
    for row in reader:
        synsets[int(row[0])] = [word for word in row[2].split(', ') if word]
        for word in row[2].split(', '):
            if word:
                index[word] = int(row[0])

with open('02-edges.txt') as fr, open('04-edges-pre.txt', 'w', newline='') as fw:
    writer  = csv.writer(fw,  dialect='excel-tab', lineterminator='\n')
    for line in fr:
        word1, word2, weight = line.rstrip().split('\t', 2)
        if word1 in index and word2 in index and index[word1] != index[word2]:
            writer.writerow((index[word1], index[word2], weight))

with open('04-nodes.csv', 'w', newline='') as f:
    writer = csv.writer(f, dialect='excel', lineterminator='\n')
    writer.writerow(('id', 'label'))
    for sid, words in synsets.items():
        label = ', '.join(words[:3])
        if len(words) > 3:
            label += ', ...'
        writer.writerow((sid, '%s: %s' % (sid, label)))
