#!/usr/bin/awk -f
BEGIN {
    FS = "\t";

    LABEL         = "<http://www.w3.org/2000/01/rdf-schema#label>";
    TYPE          = "<http://www.w3.org/1999/02/22-rdf-syntax-ns#type>";

    CONCEPT       = "<http://www.w3.org/2004/02/skos/core#Concept>";
    LEXICALSENSE  = "<http://lemon-model.net/lemon#LexicalSense>";
    WORD          = "<http://lemon-model.net/lemon#Word>";
    FORM          = "<http://lemon-model.net/lemon#Form>";

    WRITTENREP    = "<http://lemon-model.net/lemon#writtenRep>";
    CANONICALFORM = "<http://lemon-model.net/lemon#canonicalForm>";
    BROADER       = "<http://lemon-model.net/lemon#broader>";
    NARROWER      = "<http://lemon-model.net/lemon#narrower>";
    SENSE         = "<http://lemon-model.net/lemon#sense>";
    ISSENSEOF     = "<http://lemon-model.net/lemon#isSenseOf>";
    REFERENCE     = "<http://lemon-model.net/lemon#reference>";
    ISREFERENCEOF = "<http://lemon-model.net/lemon#isReferenceOf>";
}
{
    nsenses = split($3, senses, ", ");
    nisas   = split($5, isas,   ", ");

    if (nsenses == 0 || nisas == 0) next;

    print ":c" $1, TYPE, CONCEPT, ".";

    for (sense_id in senses) {
        sense = senses[sense_id];

        sub(":.*$", "", sense);

        if (!(sense in sindex)) {
            sindex[sense] = scount++;

            word = sense;
            gsub("_", " ",  word);
            sub("#.*$", "", word);

            if (!(word in windex)) {
                windex[word] = wcount++;

                print ":w" windex[word], TYPE,          WORD,              ".";
                print ":w" windex[word], LABEL,         "\"" word "\"",    ".";
                print ":f" windex[word], TYPE,          FORM,              ".";
                print ":f" windex[word], LABEL,         "\"" word "\"",    ".";
                print ":f" windex[word], WRITTENREP,    "\"" word "\"",    ".";
                print ":w" windex[word], CANONICALFORM, ":f" windex[word], ".";
            }

            print ":s" sindex[sense], TYPE,          LEXICALSENSE,       ".";
            print ":s" sindex[sense], LABEL,         "\"" sense "\"",    ".";
            print ":s" sindex[sense], ISSENSEOF,     ":w" windex[word],  ".";
            print ":w" windex[word],  SENSE,         ":s" sindex[sense], ".";
            print ":s" sindex[sense], REFERENCE,     ":c" $1,            ".";
            print ":c" $1,            ISREFERENCEOF, ":s" sindex[sense], ".";
        }

        for (isa_id in isas) {
            isa = isas[isa_id];

            sub(":.*$", "", isa);

            if (!(isa in sindex)) {
                sindex[isa] = scount++;

                word = isa;
                gsub("_", " ",  word);
                sub("#.*$", "", word);

                if (!(word in windex)) {
                    windex[word] = wcount++;

                    print ":w" windex[word], TYPE,          WORD,              ".";
                    print ":w" windex[word], LABEL,         "\"" word "\"",    ".";
                    print ":f" windex[word], TYPE,          FORM,              ".";
                    print ":f" windex[word], LABEL,         "\"" word "\"",    ".";
                    print ":f" windex[word], WRITTENREP,    "\"" word "\"",    ".";
                    print ":w" windex[word], CANONICALFORM, ":f" windex[word], ".";
                }

                print ":s" sindex[isa],  TYPE,      LEXICALSENSE,      ".";
                print ":s" sindex[isa],  LABEL,     "\"" isa "\"",     ".";
                print ":s" sindex[isa],  ISSENSEOF, ":w" windex[word], ".";
                print ":w" windex[word], SENSE,     ":s" sindex[isa],  ".";
            }

            print ":s" sindex[sense], BROADER,  ":s" sindex[isa],   ".";
            print ":s" sindex[isa],   NARROWER, ":s" sindex[sense], ".";
        }
    }
}
