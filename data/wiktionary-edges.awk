#!/usr/bin/awk -f
# echo -e 'words\ncar;auto;ride' | ./00-extract.awk
BEGIN {
    FS  = "\t";
    OFS = "\t";
}
($2 != $3) && ($4 == "synonyms") {
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

    if ($2 && $3) print $2, $3 ORS $3, $2;
}
