#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    if (length(T) == 0) T = 0;
}
{
    gsub(/:[[:digit:]]+(|\.[[:digit:]]+)/, "", $3);

    print $1, $2;

    for (i = 1; (i <= split($3, words, ", ")) && (T == 0 || i <= T); i++) {
        if (!words[i]) continue;

        gsub(/ /, "_", words[i]);

        if (words[i] != $2) {
            print $1, words[i];
        }
    }
}
