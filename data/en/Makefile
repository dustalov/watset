export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export SHELL:=/bin/bash

all: raw graph gold

raw: enwiktionary-20170201-unfiltered.tsv

enwiktionary-20170201.tsv:
	curl -sLO 'http://depot.nlpub.ru/wiktionary/enwiktionary-20170201.tsv'

enwiktionary-20170201-unfiltered.tsv:
	curl -sLO 'http://depot.nlpub.ru/wiktionary/enwiktionary-20170201-unfiltered.tsv'

graph: raw
	@echo "# Generating the word graph."
	./edges.sh

gold: wordnet twsi

wordnet: wordnet-synsets.csv
	./csv-synsets.awk wordnet-synsets.csv >wordnet-synsets.tsv
	../../pairs.awk wordnet-synsets.tsv >wordnet-pairs.txt

wordnet-synsets.csv:
	@echo "# Downloading the processed WordNet."	
	curl -sLO http://panchenko.me/data/joint/watset/wordnet-synsets.csv

twsi: twsi-synsets.csv
	./csv-synsets.awk twsi-synsets.csv >twsi-synsets.tsv
	../../pairs.awk twsi-synsets.tsv >twsi-pairs.txt

twsi-synsets.csv:
	@echo "# Downloading the processed TWSI."
	curl -sLO http://panchenko.me/data/joint/watset/twsi-synsets.csv

clean:
	rm -fv *.txt *.tsv *.csv
