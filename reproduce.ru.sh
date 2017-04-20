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
ln -sfTv ru/edges.count.txt data/edges.txt
make impl
mkdir -p eval/ru/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/count

make -C impl clean
ln -sfTv ru/edges.ones.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/ru/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/ones

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/ru/edges.count.txt >data/ru/edges.w2v.txt
ln -sfTv ru/edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/ru/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/ru/w2v

eval/pairwise.py --significance --gold=data/ru/rwn-pairs.txt eval/ru/**/*-pairs.txt | tee pairwise-ru-rwn.tsv | sort -t $'\t' -g -k9r | column -t
eval/pairwise.py --significance --gold=data/ru/yarn-pairs.txt eval/ru/**/*-pairs.txt | tee pairwise-ru-yarn.tsv | sort -t $'\t' -g -k9r | column -t

eval/cluster.sh data/ru/rwn-synsets.tsv eval/ru/**/*-synsets.tsv | tee cluster-ru-rwn.tsv | column -t
eval/cluster.sh data/ru/yarn-synsets.tsv eval/ru/**/*-synsets.tsv | tee cluster-ru-yarn.tsv | column -t

join --header -j 1 -t $'\t' >results-ru-rwn.tsv \
  <(head -1 pairwise-ru-rwn.tsv; tail -n+2 pairwise-ru-rwn.tsv | sed -re 's/-pairs.txt\t/\t/g'   | sort) \
  <(head -1 cluster-ru-rwn.tsv;  tail -n+2 cluster-ru-rwn.tsv  | sed -re 's/-synsets.tsv\t/\t/g' | sort)

join --header -j 1 -t $'\t' >results-ru-yarn.tsv \
  <(head -1 pairwise-ru-yarn.tsv; tail -n+2 pairwise-ru-yarn.tsv | sed -re 's/-pairs.txt\t/\t/g'   | sort) \
  <(head -1 cluster-ru-yarn.tsv;  tail -n+2 cluster-ru-yarn.tsv  | sed -re 's/-synsets.tsv\t/\t/g' | sort)

eval/pairwise.py --gold=data/ru/rwn-pairs.txt data/ru/yarn-pairs.txt ../babelnet-extract/pairs.ru.txt | tee pairwise-ru-xres-rwn.tsv
eval/pairwise.py --gold=data/ru/yarn-pairs.txt data/ru/rwn-pairs.txt ../babelnet-extract/pairs.ru.txt | tee pairwise-ru-xres-yarn.tsv
eval/pairwise.py --gold=../babelnet-extract/pairs.ru.txt data/ru/rwn-pairs.txt data/ru/yarn-pairs.txt | tee pairwise-ru-xres-babelnet.tsv
