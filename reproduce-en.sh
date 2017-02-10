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
ln -sfTv en/edges.count.txt data/edges.txt
make impl
mkdir -p eval/en/count
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/count

make -C impl clean
ln -sfTv en/edges.ones.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/en/ones
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/ones

make -C impl clean
./similarities.py ../projlearn/GoogleNews-vectors-negative300.bin <data/en/edges.count.txt >data/en/edges.w2v.txt
ln -sfTv en/edges.w2v.txt data/edges.txt
make impl
rm -fv impl/{cpm,dummy}*.{txt,tsv}
mkdir -p eval/en/w2v
mv -fv impl/*-pairs.txt impl/*-synsets.tsv eval/en/w2v

eval/pairwise.py --gold=data/en/wordnet-pairs.txt eval/en/**/*-pairs.txt | tee pairwise-en-wordnet.tsv | sort -t $'\t' -g -k9r | column -t
eval/pairwise.py --gold=../babelnet-extract/pairs.en.txt eval/en/**/*-pairs.txt | tee pairwise-en-babelnet.tsv | sort -t $'\t' -g -k9r | column -t
eval/pairwise.py --gold=data/en/twsi-pairs.txt eval/en/**/*-pairs.txt | tee pairwise-en-twsi.tsv | sort -t $'\t' -g -k9r | column -t

eval/cluster.sh data/en/wordnet-synsets.tsv eval/en/**/*-synsets.tsv | tee cluster-en-wordnet.tsv | column -t
NONMI=1 eval/cluster.sh ../babelnet-extract/synsets.en.tsv eval/en/**/*-synsets.tsv | tee cluster-en-babelnet.tsv | column -t
eval/cluster.sh data/en/twsi-synsets.tsv eval/en/**/*-synsets.tsv | tee cluster-en-twsi.tsv | column -t

join --header -j 1 -t $'\t' >results-en-wordnet.tsv \
  <(head -1 pairwise-en-wordnet.tsv; tail -n+2 pairwise-en-wordnet.tsv | sed -re 's/-pairs.txt\t/\t/g'   | sort) \
  <(head -1 cluster-en-wordnet.tsv;  tail -n+2 cluster-en-wordnet.tsv  | sed -re 's/-synsets.tsv\t/\t/g' | sort)

join --header -j 1 -t $'\t' >results-en-babelnet.tsv \
  <(head -1 pairwise-en-babelnet.tsv; tail -n+2 pairwise-en-babelnet.tsv | sed -re 's/-pairs.txt\t/\t/g'   | sort) \
  <(head -1 cluster-en-babelnet.tsv;  tail -n+2 cluster-en-babelnet.tsv  | sed -re 's/-synsets.tsv\t/\t/g' | sort)

join --header -j 1 -t $'\t' >results-en-twsi.tsv \
  <(head -1 pairwise-en-twsi.tsv; tail -n+2 pairwise-en-twsi.tsv | sed -re 's/-pairs.txt\t/\t/g'   | sort) \
  <(head -1 cluster-en-twsi.tsv;  tail -n+2 cluster-en-twsi.tsv  | sed -re 's/-synsets.tsv\t/\t/g' | sort)

eval/pairwise.py --gold=data/en/wordnet-pairs.txt ../babelnet-extract/pairs.en.txt data/en/twsi-pairs.txt | tee pairwise-en-xres-wordnet.tsv
eval/pairwise.py --gold=../babelnet-extract/pairs.en.txt data/en/wordnet-pairs.txt data/en/twsi-pairs.txt | tee pairwise-en-xres-babelnet.tsv
eval/pairwise.py --gold=data/en/twsi-pairs.txt data/en/wordnet-pairs.txt ../babelnet-extract/pairs.en.txt | tee pairwise-en-xres-twsi.tsv
