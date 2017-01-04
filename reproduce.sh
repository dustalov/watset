#!/bin/bash -e

export LANG=en_US.utf8

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data

cp -fv data/edges.txt data/edges.count.txt
make impl
eval/pairwise.py --gold=data/ruthes-pairs.txt impl/*-pairs.txt | tee pairwise-count.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt impl/*-pairs.txt | tee pairwise-count.tsv | column -t

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' -i data/edges.txt
make impl
eval/pairwise.py --gold=data/ruthes-pairs.txt impl/*-pairs.txt | tee pairwise-ones.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt impl/*-pairs.txt | tee pairwise-ones.tsv | column -t

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
cp -fv data/edges.w2v.txt data/edges.txt
make impl
eval/pairwise.py --gold=data/ruthes-pairs.txt impl/*-pairs.txt | tee pairwise-sim.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt impl/*-pairs.txt | tee pairwise-sim.tsv | column -t
