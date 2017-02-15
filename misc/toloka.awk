#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    print "INPUT:hyponym", "INPUT:hypernym", "INPUT:genitive", "GOLDEN:judgement", "HINT:text";
}
NR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;
    next;
}
!$ix["found"] {
    next;
}
{
    hypernyms[$ix["hypernym"] OFS $ix["genitive"]];
}
$ix["hyponym"] != hyponym {
    for (hypernym_genitive in hypernyms) {
        print $ix["hyponym"], hypernym_genitive, "", "";
    }

    hyponym = $ix["hyponym"];
    delete hypernyms;
}
END {
    for (hypernym_genitive in hypernyms) {
        print $ix["hyponym"], hypernym_genitive, "", "";
    }
}
