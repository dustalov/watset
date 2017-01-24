#!/bin/bash -e

export LANG=en_US.UTF-8 LC_COLLATE=C

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

rm -rfv eval/ru

make data-ru

make -C impl clean
mv -fv data/edges.txt data/edges.count.txt
ln -sfTv edges.count.txt data/edges.txt
make impl
mkdir -p eval/ru/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/count

make -C impl clean
sed -re 's/[[:digit:]]+$/1/g' data/edges.count.txt > data/edges.ones.txt
ln -sfTv edges.ones.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/ru/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/ones

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.count.txt >data/edges.w2v.txt
ln -sfTv edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/ru/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/w2v

eval/pairwise.py --gold=data/ru/ruthes-pairs.txt data/ru/yarn-pairs.txt eval/ru/**/*-pairs.txt | tee pairwise-ru-ruthes.tsv | sort -t $'\t' -g -k6r | column -t
eval/pairwise.py --gold=data/ru/yarn-pairs.txt data/ru/ruthes-pairs.txt eval/ru/**/*-pairs.txt | tee pairwise-ru-yarn.tsv | sort -t $'\t' -g -k6r | column -t

eval/cluster.sh data/ru/ruthes-synsets.tsv data/ru/yarn-synsets.tsv eval/ru/**/*-synsets.tsv | tee cluster-ru-ruthes.tsv | column -t
eval/cluster.sh data/ru/yarn-synsets.tsv data/ru/ruthes-synsets.tsv eval/ru/**/*-synsets.tsv | tee cluster-ru-yarn.tsv | column -t

join --header -j 1 -t $'\t' >results-ru-ruthes.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-ru-ruthes.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-ru-ruthes.tsv)

join --header -j 1 -t $'\t' >results-ru-yarn.tsv \
  <(sed -re 's/-pairs.txt\t/\t/g' pairwise-ru-yarn.tsv) \
  <(sed -re 's/-synsets.tsv\t/\t/g' cluster-ru-yarn.tsv)
