#!/bin/bash -ex
cat <(./wiktionary-edges.awk wiktionary.tsv) <(./abramov-edges.awk abramov.dat) <(./unldc-edges.awk unldc.tsv) |
sed -e 's/ {2,}//g' |
sort --parallel=$(nproc) -s |
./count.awk > edges.txt
(echo 'source,target,weight,type'; sed -e 's/\t/,/g' -e 's/$/,undirected/g' <edges.txt) >edges.csv
