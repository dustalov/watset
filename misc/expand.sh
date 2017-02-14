#!/bin/bash -ex
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

W2V=all.norm-sz500-w10-cb0-it3-min5.w2v

CLUSTERS=20170122-russian/sz500-k20-l1.0

MODEL=regularized_synonym

for ISAS in $@; do
  if [ ${ISAS:-13} == "-exp-isas.txt" ]; then
    continue
  fi

  EXPANDED=${ISAS%-isas.txt}-exp

  $CWD/../../projlearn/expand.py \
    --w2v=$CWD/../../projlearn/$W2V \
    --kmeans=$CWD/../../projlearn/$CLUSTERS/kmeans.pickle \
    --path=$CWD/../../projlearn/$CLUSTERS \
    --model=$MODEL "$ISAS" |
  tee $EXPANDED.txt | $CWD/exp-isas.awk -v T=$THRESHOLD > $EXPANDED-isas.txt
done
