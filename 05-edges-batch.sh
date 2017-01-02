#!/bin/bash -ex
export LANG=en_US.UTF-8
./04-nodes.py
LC_ALL=C sort --parallel=8 -s 04-edges-pre.txt |
./01-count.awk > 05-edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <05-edges.txt) >05-edges.csv
