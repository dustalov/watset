# Watset: Automatic Induction of Synsets from a Graph of Synonyms

Watset is a local-global meta-algorithm for fuzzy graph clustering. The underlying principle is to discover the word senses based on a *local* graph clustering, and then to induce synsets using *global* clustering.

Originally, Watset is designed for addressing the synset induction problem. Despite its simplicity, Watset shows excellent results, outperforming five competitive state-of-the-art methods in terms of F-score on four gold standard datasets for English and Russian derived from large-scale manually constructed lexical resources.

## Outline

A synonymy dictionary can be perceived as a graph, where the nodes correspond to lexical entries (words) and the edges connect pairs of the nodes when the synonymy relation between them holds. The cliques in such a graph naturally form densely connected sets of synonyms corresponding to concepts. Given the fact that solving the clique problem exactly in a graph is NP-complete and that these graphs typically contain tens of thousands of nodes, it is reasonable to use efficient hard graph clustering algorithms, like MCL and CW, for finding a global segmentation of the graph.

However, the hard clustering property of these algorithm does not handle polysemy: while one word could have several senses, it will be assigned to only one cluster. To deal with this limitation, a word sense induction procedure is used to induce senses for all words, one at the time, to produce a disambiguated version of the graph where a word is now represented with one or many word senses.

More specifically, the method consists of five steps presented: (1) learning word embeddings; (2) constructing the ambiguous weighted graph of synonyms *G*; (3) inducing the word senses; (4) constructing the disambiguated weighted graph *G'* by disambiguating of neighbors with respect to the induced word senses; (5) global clustering of the disambiguated graph.

## Citation

* [Ustalov, D.](https://github.com/dustalov), [Panchenko, A.](https://www.inf.uni-hamburg.de/en/inst/ab/lt/people/alexander-panchenko.html), [Biemann, C.](https://www.inf.uni-hamburg.de/en/inst/ab/lt/people/chris-biemann.html): [Watset: Automatic Induction of Synsets from a Graph of Synonyms](https://doi.org/10.18653/v1/P17-1145). In: Proceedings of the 55th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers), Vancouver, Canada, Association for Computational Linguistics (2017) 1579–1590

```latex
@inproceedings{Ustalov:17:acl,
  author    = {Ustalov, Dmitry and Panchenko, Alexander and Biemann, Chris},
  title     = {{Watset: Automatic Induction of Synsets from a Graph of Synonyms}},
  booktitle = {Proceedings of the 55th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)},
  year      = {2017},
  pages     = {1579--1590},
  doi       = {10.18653/v1/P17-1145},
  address   = {Vancouver, Canada},
  publisher = {Association for Computational Linguistics},
  language  = {english},
}
```

## Copyright

This repository contains the implementation of Watset. See LICENSE for details.
