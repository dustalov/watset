#!/usr/bin/awk -f
BEGIN {
    FS = OFS = "\t";
}
{
    nsenses = split($3, senses, ", ");
    nisas   = split($5, isas,   ", ");

    if (nsenses == 0 || nisas == 0) next;

    for (sense in senses) {
        for (isa in isas) {
            sub(/#[[:digit:]]+$/, "", senses[sense]);
            sub(/#[[:digit:]]+$/, "", isas[isa]);
            print senses[sense], isas[isa] | "sort --parallel=$(nproc) -t \"\t\" -S1G -k1,1 -s";
        }
    }
}
