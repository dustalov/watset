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
mkdir -p eval/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/count
eval/pairwise.py --gold=data/ruthes-pairs.txt eval/count/*-pairs.txt | tee pairwise-count-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt eval/count/*-pairs.txt | tee pairwise-count-yarn.tsv | column -t

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
cp -fv data/edges.ones.txt data/edges.txt
make impl
mkdir -p eval/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ones
eval/pairwise.py --gold=data/ruthes-pairs.txt eval/ones/*-pairs.txt | tee pairwise-ones-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt eval/ones/*-pairs.txt | tee pairwise-ones-yarn.tsv | column -t

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
cp -fv data/edges.w2v.txt data/edges.txt
make impl
mkdir -p eval/sim
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/sim
eval/pairwise.py --gold=data/ruthes-pairs.txt eval/sim/*-pairs.txt | tee pairwise-sim-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt eval/sim/*-pairs.txt | tee pairwise-sim-yarn.tsv | column -t

eval/pairwise.py --gold=data/ruthes-pairs.txt eval/**/*-pairs.txt | tee pairwise-all-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt eval/**/*-pairs.txt | tee pairwise-all-yarn.tsv | column -t
