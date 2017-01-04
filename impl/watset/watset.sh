#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption TOP -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-top.txt"

$CWD/disambiguate.py "$CWD/../watset-wsi-cw-top.txt" >"$CWD/../watset-cw-top-senses.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_LOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-log.txt"

$CWD/disambiguate.py "$CWD/../watset-wsi-cw-log.txt" >"$CWD/../watset-cw-log-senses.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_NOLOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-nolog.txt"

$CWD/disambiguate.py "$CWD/../watset-wsi-cw-nolog.txt" >"$CWD/../watset-cw-nolog-senses.txt"
