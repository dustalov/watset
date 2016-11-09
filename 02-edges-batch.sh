#!/bin/bash -ex
export LANG=en_US.UTF-8
#./00-yarn.awk <yarn-synsets.csv |
cat <(./00-ruwikt.awk <all_ru_pairs_ruwikt20160210_parsed.txt) \
    <(./00-abramov.awk <th_ru_RU_v2.dat) \
    <(./00-unldc.awk <russian-synsets.csv) |
sed -e 's/ {2,}//g' |
LC_ALL=C sort --parallel=8 -s |
./01-count.awk > 02-edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <02-edges.txt) >02-edges.csv
