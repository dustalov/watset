export LANG:=en_US.UTF-8
export LC_COLLATE:=C

all: pairwise cluster

pairwise:
	./pairwise.py --gold=../data/ru/ruthes-pairs.txt ../impl/*-pairs.txt | sort -t $$'\t' -g -k6r | column -t
	./pairwise.py --gold=../data/ru/yarn-pairs.txt ../impl/*-pairs.txt | sort -t $$'\t' -g -k6r | column -t

cluster:
	./cluster.sh ../data/ru/ruthes-synsets.tsv ../impl/*-synsets.tsv | sort -t $$'\t' -g -k3r | column -t
	./cluster.sh ../data/ru/yarn-synsets.tsv ../impl/*-synsets.tsv | sort -t $$'\t' -g -k3r | column -t

clean:
	find -mindepth 1 -maxdepth 1 -type d -exec rm -rfv {} \;
