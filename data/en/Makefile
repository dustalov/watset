export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export SHELL:=/bin/bash

all: raw graph gold

raw: wiktionary
	sort --parallel=$$(nproc) -t $$'\t' -S1G -k1 -k2 -o pairs.txt wiktionary-pairs.txt

wiktionary: enwiktionary-20170201-unfiltered.tsv
	../wiktionary.awk -v RELATION=SYNONYM enwiktionary-20170201-unfiltered.tsv | sed -e 's/ {2,}//g' >wiktionary-pairs.txt

enwiktionary-20170201.tsv:
	curl -sLO 'http://depot.nlpub.ru/wiktionary/enwiktionary-20170201.tsv'

enwiktionary-20170201-unfiltered.tsv:
	curl -sLO 'http://depot.nlpub.ru/wiktionary/enwiktionary-20170201-unfiltered.tsv'

graph: raw
	../count.awk pairs.txt > edges.count.txt
	sed -re 's/[[:digit:]]+$$/1/g' edges.count.txt > edges.ones.txt

gold: wordnet twsi

wordnet: wordnet-synsets.csv
	./csv-synsets.awk wordnet-synsets.csv >wordnet-synsets.tsv
	../../pairs.awk wordnet-synsets.tsv >wordnet-pairs.txt

wordnet-synsets.csv:
	curl -sLO http://panchenko.me/data/joint/watset/wordnet-synsets.csv

twsi: twsi-synsets.csv
	./csv-synsets.awk twsi-synsets.csv >twsi-synsets.tsv
	../../pairs.awk twsi-synsets.tsv >twsi-pairs.txt

twsi-synsets.csv:
	curl -sLO http://panchenko.me/data/joint/watset/twsi-synsets.csv

clean:
	rm -fv *.txt *.tsv *.csv
