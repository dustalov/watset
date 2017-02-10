#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C
../wiktionary.awk -v RELATION=SYNONYM ruwiktionary.tsv > ruwiktionary-pairs.txt
./abramov-pairs.awk abramov.dat > abramov-pairs.txt
./unldc-pairs.awk unldc.tsv > unldc-pairs.txt
sed -e 's/ {2,}//g' {ruwiktionary,abramov,unldc}-pairs.txt |
sort --parallel=$(nproc) -t $'\t' -S1G -k1 -k2 |
../count.awk > edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <edges.txt) >edges.csv
