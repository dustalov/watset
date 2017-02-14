#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

ISAS="patterns-isas.txt patterns-limit-isas.txt patterns-limit-exp-isas.txt patterns-filter-exp-isas.txt wiktionary-isas.txt joint-isas.txt joint-exp-isas.txt wiktionary-exp-isas.txt mas-isas.txt mas-exp-isas.txt watset-mcl-mcl-patterns-limit-tf-isas.txt watset-cw-nolog-mcl-joint-exp-tfidf-isas.txt watset-cw-nolog-mcl-joint-tfidf-isas.txt ruthes-isas.txt"
SEED=1337
TRAIN=50

./isa-hit.py --freq=freqrnc2012.csv -n 300 $ISAS > isa-300-hit.tsv
./hypergroup.py < isa-300-hit.tsv | ./toloka.awk > toloka-isa-300-hit.tsv

./isa-hit.py --freq=freqrnc2012.csv --skip=300 -n 300 $ISAS > isa-300-skip-300-hit.tsv
cat \
  <(head -1   isa-300-skip-300-hit.tsv) \
  <(tail -n+2 isa-300-skip-300-hit.tsv |
    sort |
    shuf --random-source=<(openssl enc -aes-256-ctr -pass "pass:$SEED" -nosalt </dev/zero 2>/dev/null) |
    head -$TRAIN) |
./hypergroup.py | ./toloka.awk >toloka-isa-train-$TRAIN-hit.tsv
