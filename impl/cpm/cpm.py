#!/usr/bin/env python

import argparse
import sys
import networkx as nx

from signal import signal, SIGINT
signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('-k', nargs='?', type=int, default=2)
args = parser.parse_args()

lines = sys.stdin.read().splitlines()

G = nx.parse_edgelist(lines, delimiter='\t', nodetype=str, data=(('weight', float),))

communities = nx.k_clique_communities(G, args.k)

for i, community in enumerate(communities):
    print('\t'.join((str(i), str(len(community)), ', '.join(community))))
