#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

for WEIGHT in tf tfidf; do
  ./link.py --synsets=synsets.tsv --isas=pairs.txt | sort -t $'\t' -k2nr -k4nr -k1n -o linked-$WEIGHT.tsv
  ./isas.awk linked-$WEIGHT.tsv >linked-$WEIGHT-isas.txt

  FILES="$FILES linked-$WEIGHT-isas.txt"

  sort --parallel=$(nproc) -S1G -t $'\t' -k1,1 -k2,2 -uo pairs-expanded.txt <pairs.txt <(./expanded.awk pairs-expansion.txt)
  ./link.py --synsets=synsets.tsv --isas=pairs-expanded.txt | sort -t $'\t' -k2nr -k4nr -k1n -o linked-$WEIGHT-expanded.tsv
  ./isas.awk linked-$WEIGHT-expanded.tsv >linked-$WEIGHT-expanded-isas.txt

  FILES="$FILES linked-$WEIGHT-expanded-isas.txt"
done

./evaluate.py --gold=ruthes-isas.txt pairs.txt pairs-expanded.txt linked-isas.txt linked-expanded-isas.txt linked-mcl-expanded-isas.txt linked-mcl-isas.txt | column -t
