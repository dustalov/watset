#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
FNR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;
    next;
}
tolower($ix["OUTPUT:judgement"]) == "true" {
    for (i = 1; i <= split($ix["INPUT:hypernym"], hypernyms, ", "); i++) {
        print $ix["INPUT:hyponym"], hypernyms[i];
    }
}
