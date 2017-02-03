#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}

($2 != $3) && ($4 == "hypernyms" || $4 == "hyponyms") {
    gsub(/<[^>]*>/, "");
    gsub(/ \(.+\)/, "");
    gsub(/'/, "");
    gsub(/[\[\]{}]{2,}/, "");

    for (i = 2; i <= 3; i++) {
        gsub(/^.+\.(|:) /, "", $i);
        gsub(/(^ +| +$)/, "", $i);
        gsub(/\{\{.+\}\}/, "", $i);
        gsub(/\}{2,} /, "", $i);
        gsub(/{-}/, "-", $i);
        gsub(/ /, "_", $i);
    }

    if (!$2 || !$3) next;

    if ($4 == "hypernyms") {
        print $2, $3;
    } else {
        print $3, $2;
    }
}
