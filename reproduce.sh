#!/bin/bash -e

export LANG=en_US.utf8

cat <<EOF
This script reproduces the results.
EOF

echo
set -x

make clean
make data
make impl

make -C impl clean
./similarities.py ../projlearn/all.norm-sz500-w10-cb0-it3-min5.w2v <data/edges.txt >data/edges.w2v.txt
mv -fv data/edges.w2v.txt data/edges.txt
make impl
