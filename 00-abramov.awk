#!/usr/bin/awk -f
BEGIN {
    FS  = "|";
    OFS = "\t";
}
NR == 1 {
  if ($0 != "UTF-8") exit 1;
}
NR > 1 && NR > NX {
  word = $1;
  NX   = NR + $2;
}
NR > 1 && NR <= NX {
    if ($1 == "(синоним)") {
        $1 = word;
        for (i = 1; i <= NF - 1; i++) {
            for (j = i + 1; j <= NF; j++) {
                print $i, $j;
                print $j, $i;
            }
        }
    }
    if (i == count) {
        count = 0;
    }
}
