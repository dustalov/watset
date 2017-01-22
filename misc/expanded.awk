#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    gsub(/:[[:digit:]]+\.[[:digit:]]+/, "", $3);

    print $1, $2;

    for (i = 1; i <= split($3, words, ", "); i++) {
        gsub(/ /, "_", words[i]);

        if (words[i] != $2) {
            print $1, words[i];
        }
    }
}
