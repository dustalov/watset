#!/usr/bin/env python3

import argparse
import sys
from signal import signal, SIGINT

import networkx as nx

signal(SIGINT, lambda signum, frame: sys.exit(1))

parser = argparse.ArgumentParser()
parser.add_argument('-k', nargs='?', type=int, default=2)
args = parser.parse_args()

lines = sys.stdin.read().splitlines()

G = nx.parse_edgelist(lines, delimiter='\t', nodetype=str, data=(('weight', float),))

communities = nx.k_clique_communities(G, args.k)

for i, community in enumerate(communities):
    print('\t'.join((str(i), str(len(community)), ', '.join(community))))
