#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
($1 != $3) && ($4 == "SYNONYM") {
    gsub(/['"]/, "");

    for (i = 1; i <= 3; i += 2) {
        gsub(/([A-Z][a-z]+):/, "", $i);
        gsub(/ /, "_", $i);
    }

    if ($1 && $3 && $1 != $3) print $1, $3 ORS $3, $1;
}
