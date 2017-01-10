#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    gsub("(#[[:digit:]]+|, $)", "");

    len = split($3, words, ", ");

    if (len >= 10000) next;

    for (i = 1; i <= len; i++) uniq[words[i]];

    for (word in uniq) {
        synset = synset sep word;
        sep = ", ";
        len++;
    }

    print $1, len, synset | "sort --parallel=$(nproc) -t \"\t\" -S1G -k2nr -k1n -s";

    synset = sep = len = ""; delete uniq;
}
