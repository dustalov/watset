#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
($4 == "HYPONYM") {
    $4 = $3; $3 = $1; $1 = $4;
    $4 = "HYPERNYM";
}
($1 != $3) && ($4 == "HYPERNYM") {
    gsub(/"/, "");

    for (i = 1; i <= 3; i += 2) {
        gsub(/ /, " ", $i);                  # nbsp to space
        gsub(/[—–]/, "-", $i);               # (m)dash to minus
        gsub(/…/, "...", $i);                # dots
        gsub(/([A-Z][a-z]+):/, "", $i);      # "Wikisaurus:word" -> "word"
        gsub(/<.+>/, "", $i);                # HTML tags
        gsub(/\{\{.+\}\}/, "", $i);          # {{label}}
        gsub(/(^| +)и +т. *[дп].$/, "", $i); # "и т. [дп]."
        gsub(/^''.+''(:|) */, "", $i);       # "''label'': word" -> "word"
        gsub(/(^| +)\[[0-9]+\]$/, "", $i);   # "word [1]" -> "word"
        gsub(/(^| +)\(.+\)$/, "", $i);       # "word (label)" -> "word"
        gsub(/ *[{}()\[\]~]+$/, "", $i);     # trailing stuff: {}()[]~
        gsub(/^\?+$/, "", $i);               # question marks
        gsub(/^&.+/, "", $i);                # "&nbsp" and others
        gsub(/ /, "_", $i);                  # spaces -> underscores

        # weird punctuation and whitespaces
        gsub(/^[\u2000-\u206F\u2E00-\u2E7F\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~\t\n\x0B\f\r]+$/, "", $i);
    }

    if ($1 && $3 && $1 != $3) print $1, $3;
}
