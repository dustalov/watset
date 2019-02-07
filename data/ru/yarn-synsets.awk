#!/usr/bin/gawk -f
BEGIN {
    FS  = ",";
    OFS = "\t";
    grammar["n"];
    grammar["v"];
    grammar["a"];
    grammar["mwn"];
}
NR == 1 {
    for (i=1; i<=NF; i++) ix[$i] = i;
}
NR > 1 && $ix["grammar"] in grammar && (length(V) == 0 || $ix["version"] >= V) {
    gsub(/ /, "_", $ix["words"]);
    for (i = 1; i <= split($ix["words"], words, ";"); i++) uniq[words[i]];
    for (word in uniq) {
        synset = synset sep word;
        sep = ", ";
        len++;
    }
    print $1, len, synset;
    synset = sep = len = ""; delete uniq;
}
