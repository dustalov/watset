#!/usr/bin/gawk -f
BEGIN {
    FS  = "|";
    OFS = "\t";
}
NR == 1 {
  if ($0 != "UTF-8") exit 1;
  next;
}
NR > NX {
  word = $1;
  NX   = NR + $2;
}
NR <= NX {
    if ($1 == "(синоним)") {
        $1 = word;

        gsub(/ \(.+\)/, "");

        for (i = 1; i <= NF - 1; i++) {
            for (j = i + 1; j <= NF; j++) {
                gsub(/(^ +| +$)/, "", $i);
                gsub(/(^ +| +$)/, "", $j);
                gsub(/ /, "_", $i);
                gsub(/ /, "_", $j);
                if ($i != $j) print $i, $j ORS $j, $i;
                if (!$i || !$j) {
                    print NR, $i, $j >"/dev/stderr";
                    exit 2;
                }
            }
        }
    }
    if (i == count) {
        count = 0;
    }
}
