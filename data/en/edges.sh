#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C
./wiktionary-edges.awk enwiktionary.tsv |
sed -e 's/ {2,}//g' |
sort --parallel=$(nproc) -t $'\t' -S1G -k1 -k2 |
../count.awk > edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <edges.txt) >edges.csv
