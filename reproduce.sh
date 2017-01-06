#!/bin/bash -e

export LANG=en_US.utf8

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data

mv -fv data/edges.txt data/edges.count.txt
ln -sfTv edges.count.txt data/edges.txt
make impl
mkdir -p eval/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/count
eval/pairwise.py --gold=data/ruthes-pairs.txt --lexicon=joint eval/count/*-pairs.txt | tee pairwise-count-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt --lexicon=joint eval/count/*-pairs.txt | tee pairwise-count-yarn.tsv | column -t

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
ln -sfTv edges.ones.txt data/edges.txt
make impl
mkdir -p eval/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ones
eval/pairwise.py --gold=data/ruthes-pairs.txt --lexicon=joint eval/ones/*-pairs.txt | tee pairwise-ones-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt --lexicon=joint eval/ones/*-pairs.txt | tee pairwise-ones-yarn.tsv | column -t

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
mkdir -p eval/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/w2v
eval/pairwise.py --gold=data/ruthes-pairs.txt --lexicon=joint eval/w2v/*-pairs.txt | tee pairwise-w2v-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt --lexicon=joint eval/w2v/*-pairs.txt | tee pairwise-w2v-yarn.tsv | column -t

eval/pairwise.py --gold=data/ruthes-pairs.txt --lexicon=conjoint eval/**/*-pairs.txt | tee pairwise-ruthes-conjoint.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt --lexicon=conjoint eval/**/*-pairs.txt | tee pairwise-yarn-conjoint.tsv | column -t

eval/pairwise.py --gold=data/ruthes-pairs.txt eval/**/*-pairs.txt | tee pairwise-ruthes.tsv | column -t
eval/pairwise.py --gold=data/yarn-pairs.txt eval/**/*-pairs.txt | tee pairwise-yarn.tsv | column -t
