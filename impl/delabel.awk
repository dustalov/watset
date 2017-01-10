#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    gsub("(#[[:digit:]]+|, $)", "");

    for (i = 1; i <= split($3, words, ", "); i++) uniq[words[i]];

    for (word in uniq) {
        synset = synset sep word;
        sep = ", ";
        len++;
    }

    print $1, len, synset | "sort --parallel=$(nproc) -t \"\t\" -S1G -k2nr -k1n -s";

    synset = sep = len = ""; delete uniq;
}
