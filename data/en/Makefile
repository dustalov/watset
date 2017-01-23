export LANG:=en_US.UTF-8
export LC_COLLATE:=C
export LC_CTYPE:=C

all: raw graph gold

raw: enwiktionary.tsv

enwiktionary.tsv:

graph: raw
	@echo "# Generating the word graph."
	./edges.sh

gold: wordnet twsi

wordnet: wordnet-synsets.csv
	./csv-edges.awk wordnet-synsets.csv >wordnet-pairs.txt

wordnet-synsets.csv:
	@echo "# Downloading the processed WordNet."	
	curl -sLO http://panchenko.me/data/joint/watset/wordnet-synsets.csv

twsi: twsi-synsets.csv
	./csv-edges.awk twsi-synsets.csv >twsi-pairs.txt

twsi-synsets.csv:
	@echo "# Downloading the processed TWSI."
	curl -sLO http://panchenko.me/data/joint/watset/twsi-synsets.csv

clean:
	rm -fv *.txt *.tsv *.csv
