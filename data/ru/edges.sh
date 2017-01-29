#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C
cat <(./wiktionary-edges.awk wiktionary.tsv) <(./abramov-edges.awk abramov.dat) <(./unldc-edges.awk unldc.tsv) |
sed -e 's/ {2,}//g' |
sort --parallel=$(nproc) -t $'\t' -S1G -k1 -k2 |
../count.awk > edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <edges.txt) >edges.csv
