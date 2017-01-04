#!/bin/bash -ex
export LANG=en_US.UTF-8

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption TOP \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-top.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_LOG \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-log.txt"

java -Xms16G -Xmx16G -cp "$CWD/../../../chinese-whispers/target/chinese-whispers.jar" \
     de.tudarmstadt.lt.cw.global.CWGlobal -N 200 -cwOption DIST_NOLOG \
     -in "$CWD/../../data/edges.txt" -out "$CWD/../cw-nolog.txt"
