#!/bin/bash -e

export LANG=en_US.utf8

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

./02-edges-batch.sh
./03-cw.sh
./05-edges-batch.sh
./06-eval-pairs.awk 03-cw.txt >06-cw-pairs.txt
./06-eval-pairs.awk 03-maxmax.txt >06-maxmax-pairs.txt
./10-disambiguate.py >10-senses.txt
./11-cw.sh
./12-delabel.awk 11-synsets.txt >12-synsets.txt
./13-lexicon.awk 12-synsets.txt >13-lexicon.txt
./20-our-pairs.awk 12-synsets.txt >20-our-pairs.txt
