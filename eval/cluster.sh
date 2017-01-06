#!/bin/bash -ex
set -o pipefail
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GOLD=$1; shift

if [ -z "$GOLD" ]; then
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

sort --parallel=$(nproc) -S1G -suo "$RESOURCE_DATA" "$RESOURCE_DATA"

comm -12 "$GOLD_DATA" "$RESOURCE_DATA" > $LEXICON

# Then, GOLD_DATA and RESOURCE_DATA are used to store the CNL data
# representing the synsets.

$CWD/cnl.py "$LEXICON" < $GOLD > $GOLD_DATA
FLOAT='([[:digit:]]+(|\.[[:digit:]]+))'

echo -e "path\tnmi\tfnmi\tnmi_max\tnmi_sum\tnmi_lfk"

for RESOURCE in $@; do
  $CWD/cnl.py "$LEXICON" < $RESOURCE > $RESOURCE_DATA

  GENCONVNMI=$($CWD/../../GenConvNMI/bin/Release/gecmi -f "$GOLD_DATA" "$RESOURCE_DATA" |
               sed -re "s/^NMI: $FLOAT, FNMI: $FLOAT.*$/\1\t\3/g")

  OVPNMI=$($CWD/../../OvpNMI/bin/Release/onmi -a "$GOLD_DATA" "$RESOURCE_DATA" |
           sed -re "s/^NMImax: $FLOAT, NMIsum: $FLOAT, NMIlfk: $FLOAT.*$/\1\t\3\t\5/g")

  echo -e "$RESOURCE\t$GENCONVNMI\t$OVPNMI"
done
