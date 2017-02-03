#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

W2V=all.norm-sz500-w10-cb0-it3-min5.w2v

CLUSTERS=20170122-russian/sz500-k20-l1.0

MODEL=regularized_synonym

for ISAS in $@; do
  EXPANDED=${ISAS%-isas.txt}-exp-isas.txt

  $CWD/../../projlearn/expand.py \
    --w2v=$CWD/../../projlearn/$W2V \
    --kmeans=$CWD/../../projlearn/$CLUSTERS/kmeans.pickle \
    --path=$CWD/../../projlearn/$CLUSTERS \
    --model=$MODEL $ISAS |
  $CWD/expanded.awk >$EXPANDED
done
