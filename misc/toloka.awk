#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    print "INPUT:hyponym", "INPUT:hypernym", "INPUT:genitive", "GOLDEN:judgement", "HINT:text";
}
NR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;
    next;
}
$ix["found"] {
    print $ix["hyponym"], $ix["hypernym"], $ix["genitive"], "", "" | "sort -t \"\t\" -k1,1 -k2,2 -k3,3 -u";
}
