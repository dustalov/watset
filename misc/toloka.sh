#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

ISAS="patterns-isas.txt patterns-limit-isas.txt patterns-limit-exp-isas.txt patterns-filter-exp-isas.txt wiktionary-isas.txt joint-isas.txt joint-exp-isas.txt wiktionary-exp-isas.txt mas-isas.txt mas-exp-isas.txt watset-mcl-mcl-patterns-limit-tf-isas.txt watset-cw-nolog-mcl-joint-exp-tfidf-isas.txt watset-cw-nolog-mcl-joint-tfidf-isas.txt ruthes-isas.txt"

SKIP=0
POOL=100

TRAIN_SEED=1337
TRAIN_SKIP=300
TRAIN_HITS=50

./isa-hit.py --freq=freqrnc2012.csv --skip=$SKIP -n=$POOL $ISAS > isa-$POOL-hit.tsv
./hypergroup.py < isa-$POOL-hit.tsv | ./toloka.awk > toloka-isa-$POOL-hit.tsv

./isa-hit.py --freq=freqrnc2012.csv --skip=$TRAIN_SKIP -n=$TRAIN_HITS $ISAS > isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv
cat \
  <(head -1   isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv) \
  <(tail -n+2 isa-$TRAIN_HITS-skip-$TRAIN_SKIP-hit.tsv |
    awk -F '\t' '!!$3' | sort |
    shuf --random-source=<(openssl enc -aes-256-ctr -pass "pass:$TRAIN_SEED" -nosalt </dev/zero 2>/dev/null) |
    head "-$TRAIN_HITS") |
./hypergroup.py | ./toloka.awk >toloka-isa-$TRAIN_HITS-skip-$TRAIN_SKIP-train-hit.tsv
