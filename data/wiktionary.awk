#!/usr/bin/gawk -f
BEGIN {
    FS = OFS = "\t";
    if (length(RELATION) == 0) exit 1;
}
$4 != toupper(RELATION) { next; }
$1 != $3 {
    gsub(/"/, "");     # quotes
    gsub(/ /, " ");    # nbsp to space
    gsub(/[—–]/, "-"); # (m)dash to minus
    gsub(/…/, "...");  # dots

    for (i = 1; i <= 3; i += 2) {
        gsub(/(^ +| +$)/, "", $i);             # trailing spaces
        gsub(/([A-Z][a-z]+):/, "", $i);        # "Wikisaurus:word" -> "word"
        gsub(/<.+>/, "", $i);                  # HTML tags
        gsub(/\{\{.+\}\}/, "", $i);            # {{label}}
        gsub(/(^| +)и +т\. *[дп]\.$/, "", $i); # "и т. [дп]."
        gsub(/^''.+''(:|) */, "", $i);         # "''label'': word" -> "word"
        gsub(/ *''.+''$/, "", $i);             # "word ''label''" -> "word"
        gsub(/^.*: */, "", $i);                # "label: word" -> "word"
        gsub(/(^| +)\[[0-9]+\]$/, "", $i);     # "word [1]" -> "word"
        gsub(/(^| +)\(.+\)$/, "", $i);         # "word (label)" -> "word"
        gsub(/ *[{}()\[\]~]+$/, "", $i);       # trailing stuff: {}()[]~
        gsub(/\?+$/, "", $i);                  # question marks
        gsub(/^&.+/, "", $i);                  # "&nbsp" and others
        gsub(/ /, "_", $i);                    # spaces -> underscores
        gsub(/(^_+|_+$)/, "", $i);             # trailing underscores

        # weird punctuation and whitespaces
        gsub(/^[\\'!"#$%&()*+,\-.\/:;<=>?@\[\]^_`{|}~\t\n\x0B\f\r]+$/, "", $i);
    }
}
$1 && $3 && $1 != $3 && $4 == "SYNONYM" {
    print $1, $3 ORS $3, $1;
}
