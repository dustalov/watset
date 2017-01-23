#!/bin/bash -e

export LANG=en_US.UTF-8 LC_COLLATE=C

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

rm -rfv eval/en

make data-en

make -C impl clean
mv -fv data/edges.txt data/edges.count.txt
ln -sfTv edges.count.txt data/edges.txt
make impl
mkdir -p eval/en/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/count

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
ln -sfTv edges.ones.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/en/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/ones

make -C impl clean
./similarities.py ../projlearn/GoogleNews-vectors-negative300.bin <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/en/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/w2v

eval/en/pairwise.py --gold=data/en/wordnet-pairs.txt data/en/twsi-pairs.txt eval/en/**/*-pairs.txt | tee pairwise-en-wordnet.tsv | sort -t $'\t' -g -k6r | column -t
eval/en/pairwise.py --gold=data/en/twsi-pairs.txt data/en/wordnet-pairs.txt eval/en/**/*-pairs.txt | tee pairwise-en-twsi.tsv | sort -t $'\t' -g -k6r | column -t

eval/en/cluster.sh data/en/wordnet-synsets.tsv data/en/twsi-synsets.tsv eval/en/**/*-synsets.tsv | tee cluster-en-wordnet.tsv | column -t
eval/en/cluster.sh data/en/twsi-synsets.tsv data/en/wordnet-synsets.tsv eval/en/**/*-synsets.tsv | tee cluster-en-twsi.tsv | column -t

join --header -j 1 -t $'\t' >results-en-wordnet.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-en-wordnet.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-en-wordnet.tsv)

join --header -j 1 -t $'\t' >results-en-twsi.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-en-twsi.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-en-twsi.tsv)
