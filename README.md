# Concept Discovery from Synonymy Graphs

This is an implementation of concept discovery (or synset induction, if you wish) approach that uses synonymy graphs. It is based on three algorithms:

* ego-network clustering for inducing the word senses ([Panchenko et al., 2016](https://www.linguistics.rub.de/konvens16/pub/24_konvensproc.pdf)),
* cosine-based sense disambiguation for disambiguating them ([Faralli et al., 2016](http://link.springer.com/chapter/10.1007/978-3-319-46547-0_7)),
* Chinese Whispers for graph clustering ([Biemann, 2006](http://dl.acm.org/citation.cfm?id=1654774)).

However, it is not based on distributional methods.
