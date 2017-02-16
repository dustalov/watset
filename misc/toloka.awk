#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    print "INPUT:hyponym", "INPUT:hypernym", "INPUT:genitive", "GOLDEN:judgement", "HINT:text";
}
FNR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;

    if (!("hyponym" in ix) || !("hypernym" in ix) || !("genitive" in ix)) {
        print "Invalid format." > "/dev/stderr";
        exit(1);
    }

    next;
}
{
    print $ix["hyponym"], $ix["hypernym"], $ix["genitive"], "", "" | "sort -t \"\t\" -k1,1 -k2,2 -k3,3 -u";
}
