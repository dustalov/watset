#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    print "word", "cid", "cluster", "isas";
}
$2 > 0 {
    gsub(/ /, "", $3);
    gsub(/,/, ":1.0,", $3);
    sub(/$/, ":1.0", $3);
    print "s" $1, 0, $3, "";
}
$4 > 0 {
    gsub(/ /, "", $5);
    print "h" $1, 0, $5, "";
}
