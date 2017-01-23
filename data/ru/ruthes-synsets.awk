#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    $3 = tolower($3);
    gsub(/ /, "_", $3);

    for (i = 1; i <= split($3, words, "|"); i++) uniq[words[i]];

    for (word in uniq) {
        synset = synset sep word;
        sep = ", ";
        len++;
    }
    print $1, len, synset;
    synset = sep = len = ""; delete uniq;
}
