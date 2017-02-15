#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

ISAS="ruthes-isas.txt \
patterns-isas.txt \
patterns-limit-isas.txt \
patterns-limit-exp-isas.txt \
patterns-filter-exp-isas.txt \
wiktionary-isas.txt \
wiktionary-exp-isas.txt \
mas-isas.txt \
mas-exp-isas.txt \
joint-isas.txt \
joint-exp-isas.txt \
watset-mcl-mcl-patterns-limit-tf-isas.txt \
watset-cw-nolog-mcl-joint-exp-tfidf-isas.txt \
watset-cw-nolog-mcl-joint-tfidf-isas.txt"

SKIP=0
STEP=10
WORDS=100

TRAIN_SEED=1337
TRAIN_SKIP=300
TRAIN_HITS=50

# Actual HIT

./isa-hit.py --freq=freqrnc2012.csv --skip=$SKIP -n=$WORDS $ISAS > isa-$WORDS-hit.tsv

./hypergroup.py < isa-$WORDS-hit.tsv > hg-isa-$WORDS-hit.tsv

./toloka.awk hg-isa-$WORDS-hit.tsv > toloka-isa-$WORDS-hit.tsv

for i in $(seq $STEP $STEP $WORDS); do
  OFFSET=$((SKIP+i-STEP))

  ./isa-hit.py --freq=freqrnc2012.csv --skip=$OFFSET -n=$STEP $ISAS > isa-$WORDS-pool-$i-hit.tsv

  ./hypergroup.py < isa-$WORDS-pool-$i-hit.tsv > hg-isa-$WORDS-pool-$i-hit.tsv

  ./toloka.awk hg-isa-$WORDS-pool-$i-hit.tsv > toloka-isa-$WORDS-pool-$i-hit.tsv
done

# Training HIT

./isa-hit.py --freq=freqrnc2012.csv --skip=$TRAIN_SKIP -n=$TRAIN_HITS $ISAS > isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv

cat <(head -1   isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv) \
    <(tail -n+2 isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv |
      awk -F '\t' '!!$3' | sort |
      shuf --random-source=<(openssl enc -aes-256-ctr -pass "pass:$TRAIN_SEED" -nosalt </dev/zero 2>/dev/null) |
      head "-$TRAIN_HITS" |
      sort -t $'\t' -k2 -k5) >isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv

./hypergroup.py < isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv > hg-isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv

./toloka.awk hg-isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv > toloka-isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv
