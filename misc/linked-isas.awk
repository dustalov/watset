#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
    if (length(SENSES) == 0) SENSES = 0;
}
{
    nsenses = split($3, senses, ", ");
    nisas   = split($5, isas,   ", ");

    if (nsenses == 0 || nisas == 0) next;

    for (sense in senses) {
        for (isa in isas) {
            if (SENSES) {
                sub(/(:|$)/, OFS, isas[isa]);
            } else {
                sub(/#[[:digit:]]+$/, "", senses[sense]);
                sub(/#[[:digit:]]+(:|$)/, OFS, isas[isa]);
            }
            print senses[sense], isas[isa] | "sort --parallel=$(nproc) -t \"\t\" -S1G -s -g -k3r | cut -f1,2";
        }
    }
}
