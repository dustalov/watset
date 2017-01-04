#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption TOP -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-top.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_LOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-log.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.wsi.WSI -clustering cw -cwOption DIST_NOLOG -N 200 -n 200 -e 0 \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../watset-wsi-cw-nolog.txt"

for setup in cw-top cw-log cw-nolog; do
  $CWD/disambiguate.py "$CWD/../watset-wsi-$setup.txt" >"$CWD/../watset-$setup-senses.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption TOP \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-top-synsets.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_LOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-log-synsets.txt"

  java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
       de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_NOLOG \
       -in "$CWD/../watset-$setup-senses.txt" -out "$CWD/../watset-$setup-cw-nolog-synsets.txt"
done
