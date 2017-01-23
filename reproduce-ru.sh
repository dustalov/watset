#!/bin/bash -e

export LANG=en_US.UTF-8 LC_COLLATE=C

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data-ru

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
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/w2v

eval/pairwise.py --gold=data/ru/ruthes-pairs.txt data/ru/yarn-pairs.txt eval/**/*-pairs.txt | tee pairwise-ru-ruthes.tsv | sort -t $'\t' -g -k6r | column -t
eval/pairwise.py --gold=data/ru/yarn-pairs.txt data/ru/ruthes-pairs.txt eval/**/*-pairs.txt | tee pairwise-ru-yarn.tsv | sort -t $'\t' -g -k6r | column -t

eval/cluster.sh data/ru/ruthes-synsets.tsv data/ru/yarn-synsets.tsv eval/**/*-synsets.tsv | tee cluster-ru-ruthes.tsv | column -t
eval/cluster.sh data/ru/yarn-synsets.tsv data/ru/ruthes-synsets.tsv eval/**/*-synsets.tsv | tee cluster-ru-yarn.tsv | column -t

join --header -j 1 -t $'\t' >results-ru-ruthes.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-ru-ruthes.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-ru-ruthes.tsv)

join --header -j 1 -t $'\t' >results-ru-yarn.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-ru-yarn.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-ru-yarn.tsv)
