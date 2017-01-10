export LANG:=en_US.UTF-8
export LC_ALL:=C

all: pairwise cluster

pairwise:
	./pairwise.py --gold=../data/ruthes-pairs.txt ../impl/*-pairs.txt | column -t
	./pairwise.py --gold=../data/yarn-pairs.txt ../impl/*-pairs.txt | column -t

cluster:
	./cluster.sh ../data/ruthes-synsets.tsv ../impl/*-synsets.tsv | column -t
	./cluster.sh ../data/yarn-synsets.tsv ../impl/*-synsets.tsv | column -t

clean:
	find -mindepth 1 -maxdepth 1 -type d -exec rm -rfv {} \;
