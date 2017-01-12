#!/usr/bin/env python

from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE, SIG_DFL)

import argparse
import sys
import networkx as nx

parser = argparse.ArgumentParser()
parser.add_argument('-k', nargs='?', type=int, default=2)
args = vars(parser.parse_args())

lines = sys.stdin.read().splitlines()

G = nx.parse_edgelist(lines, delimiter='\t', nodetype=str, data=(('weight', float),))

communities = nx.k_clique_communities(G, args['k'])

for i, community in enumerate(communities):
    print('\t'.join((str(i), str(len(community)), ', '.join(community))))
