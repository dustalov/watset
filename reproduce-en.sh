#!/bin/bash -e

export LANG=en_US.UTF-8 LC_COLLATE=C

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data-en

mv -fv data/edges.txt data/edges.count.txt
ln -sfTv edges.count.txt data/edges.txt
make impl
mkdir -p eval/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/count

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
ln -sfTv edges.ones.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ones

make -C impl clean
./similarities.py ../projlearn/GoogleNews-vectors-negative300.bin <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/w2v

eval/pairwise.py --gold=data/ru/wordnet-pairs.txt data/ru/twsi-pairs.txt eval/**/*-pairs.txt | tee pairwise-en-wordnet.tsv | sort -t $'\t' -g -k6r | column -t
eval/pairwise.py --gold=data/ru/twsi-pairs.txt data/ru/wordnet-pairs.txt eval/**/*-pairs.txt | tee pairwise-en-twsi.tsv | sort -t $'\t' -g -k6r | column -t

eval/cluster.sh data/ru/wordnet-synsets.tsv data/ru/twsi-synsets.tsv eval/**/*-synsets.tsv | tee cluster-en-wordnet.tsv | column -t
eval/cluster.sh data/ru/twsi-synsets.tsv data/ru/wordnet-synsets.tsv eval/**/*-synsets.tsv | tee cluster-en-twsi.tsv | column -t

join --header -j 1 -t $'\t' >results-en-wordnet.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-en-wordnet.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-en-wordnet.tsv)

join --header -j 1 -t $'\t' >results-en-twsi.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-en-twsi.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-en-twsi.tsv)
