#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

rm -fv *-exp-isas.txt

./expand.sh {patterns,wiktionary,mas}-isas.txt

for WEIGHT in tf idf tfidf; do
for SYNSETS in *-synsets.tsv; do
for PAIRS in patterns-isas.txt; do
for ISAS in {patterns,wiktionary,mas}{,-exp}-isas.txt; do
  LINKED=${SYNSETS%-synsets.tsv}-${ISAS%-isas.txt}-linked.tsv
  ./link.py --synsets=$SYNSETS --isas=$ISAS | sort -t $'\t' -k2nr -k4nr -k1n -o "$LINKED"

  ISAS=${LINKED%-linked.tsv}-isas.txt
  ./linked-isas.awk "$LINKED" > "$ISAS"

  EVALUATE="$EVALUATE $ISAS"
done
done
done
done

./evaluate.py --gold=ruthes-isas.txt {patterns,wiktionary,mas}{,-exp}-isas.txt $EVALUTE | tee 'pairwise-ruthes.tsv' | column -t
