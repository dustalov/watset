# Watset: Automatic Induction of Synsets from a Graph of Synonyms

Watset is a local-global meta-algorithm for [fuzzy graph clustering](https://en.wikipedia.org/wiki/Fuzzy_clustering). The algorithm constructs an intermediate representation, called a *sense graph*, using a *local* graph clustering algorithm and then obtains overlapping node clusters using a *global* graph clustering algorithm.

Originally, Watset was designed for addressing the synset induction problem, which is indicated in the corresponding [ACL&nbsp;2017](https://doi.org/10.18653/v1/P17-1145) paper. Despite its simplicity, Watset shows [excellent results](https://github.com/dustalov/watset/releases), outperforming five competitive state-of-the-art methods in terms of F-score on four gold standard datasets for English and Russian derived from large-scale manually constructed lexical resources.

We found that Watset works very well not just for synset induction, but for a lot of other fuzzy clustering tasks. Please use a much faster and convenient implementation of Watset in Java: <https://github.com/nlpub/watset-java>.

## Citation

* [Ustalov, D.](https://github.com/dustalov), [Panchenko, A.](https://github.com/alexanderpanchenko), Biemann, C., Ponzetto, S.P.: [Watset: Local-Global Graph Clustering with Applications in Sense and Frame Induction](https://doi.org/10.1162/COLI_a_00354). Computational Linguistics 45(3) (2019)

```latex
@article{Ustalov:19:cl,
  author    = {Ustalov, Dmitry and Panchenko, Alexander and Biemann, Chris and Ponzetto, Simone Paolo},
  title     = {{Watset: Local-Global Graph Clustering with Applications in Sense and Frame Induction}},
  journal   = {Computational Linguistics},
  year      = {2019},
  volume    = {45},
  number    = {3},
  doi       = {10.1162/COLI_a_00354},
  publisher = {MIT Press},
  issn      = {0891-2017},
  language  = {english},
}
```

## Copyright

This repository contains the implementation of Watset. See LICENSE for details.
