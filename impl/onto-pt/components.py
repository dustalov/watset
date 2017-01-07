#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import sys
import numpy as np
import networkx as nx

lines = sys.stdin.read().splitlines()

# I do not know why nx.read_edgelist does not work.
G = nx.parse_edgelist(lines, delimiter='\t', nodetype=str, data=(('weight', float),))

index = {word: i + 1 for i, component in enumerate(sorted(nx.connected_components(G), key=len, reverse=True)) for word in component}

for word1, word2, weight in G.edges_iter(data='weight'):
    assert index[word1] == index[word2]

    if weight:
        print('\t'.join((str(index[word1]), word1, word2, str(weight))))
