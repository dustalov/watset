#!/usr/bin/awk -f
# echo -e 'words\ncar;auto;ride' | ./00-extract.awk
BEGIN {
    FS  = ",";
    OFS = "\t";
    grammar["n"];
    grammar["mwn"];
}
NR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;
}
NR > 1 && $ix["grammar"] in grammar {
    split($ix["words"], words, ";");
    for (i = 1; i <= length(words) - 1; i++) {
        for (j = i + 1; j <= length(words); j++) {
            print words[i], words[j];
            print words[j], words[i];
        }
    }
}
