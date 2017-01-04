export LANG=en_US.UTF-8

all:
	./pairwise.py --gold=../data/ruthes-pairs.txt ../impl/*-pairs.txt | column -t
	./pairwise.py --gold=../data/yarn-pairs.txt ../impl/*-pairs.txt | column -t

clean:
	find -mindepth 1 -maxdepth 1 -type d -exec rm -rfv {} \;
