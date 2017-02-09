#!/bin/bash -ex
set -o pipefail
export LANG=en_US.UTF-8 LC_COLLATE=C

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GOLD=$1; shift

if [ -z ${GOLD+x} ]; then
  echo "Usage: $0 gold-synsets.tsv [resource-synsets.tsv ...]"
  exit 1
fi

LEXICON=$(mktemp)
GOLD_DATA=$(mktemp)
RESOURCE_DATA=$(mktemp)

trap 'rm -f -- "$LEXICON" "$GOLD_DATA" "$RESOURCE_DATA"' INT TERM HUP EXIT

# At the beginning, GOLD_DATA and RESOURCE_DATA are used
# to store the lexicons.

$CWD/../lexicon.awk -v TOLOWER=1 "$GOLD" > $GOLD_DATA

for RESOURCE in $@; do
  $CWD/../lexicon.awk -v TOLOWER=1 "$RESOURCE" >> $RESOURCE_DATA
done

sort --parallel=$(nproc) -S1G -uo "$RESOURCE_DATA" "$RESOURCE_DATA"

LEXICON_SIZE=$(comm -12 "$GOLD_DATA" "$RESOURCE_DATA" | tee "$LEXICON" | wc -l)

# Then, GOLD_DATA and RESOURCE_DATA are used to store the CNL data
# representing the synsets.

$CWD/cnl.py "$LEXICON" < $GOLD > $GOLD_DATA

echo -e "path\twords\tsynsets\tlexicon\tgenconv_nmi\tovp_nmi"

for RESOURCE in $@; do
  $CWD/cnl.py "$LEXICON" < $RESOURCE > $RESOURCE_DATA

  WORDS=$($CWD/../lexicon.awk "$RESOURCE" | wc -l)
  SYNSETS=$(wc -l "$RESOURCE" | cut -f1 -d' ')

  if [ -z ${NONMI+x} ]; then
    GENCONVNMI=$($CWD/../../GenConvNMI/bin/Release/gecmi "$GOLD_DATA" "$RESOURCE_DATA" || true)
    OVPNMI=$($CWD/../../OvpNMI/bin/Release/onmi "$GOLD_DATA" "$RESOURCE_DATA" || true)
  else
    GENCONVNMI="e"
    OVPNMI="e"
  fi

  echo -e "$RESOURCE\t$WORDS\t$SYNSETS\t$LEXICON_SIZE\t$GENCONVNMI\t$OVPNMI"
done
