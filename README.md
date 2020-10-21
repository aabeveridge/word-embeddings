# Word Embeddings in R

The following tutorial introduces the `text2vec` package and the GloVe method for analyzing word embeddings. The first video below explains the rationale for the GloVe method, and the second video explains the more popular word2vec method for word embeddings:
- <https://youtu.be/InCWrgrUJT8>
- <https://youtu.be/QyrUentbkvw>

The code example provided in `word-embeddings.R` is based on the GloVe example from <http://text2vec.org/glove.html>, and like previous tutorials in this course I have modified this tutorial to use text scraped from news sites (see: 'rvest_example2.R' from the [freq-ngrams-corr](https://github.com/aabeveridge/freq-ngrams-corr) repository).

Additionally, there is an updated rvest example file included with this tutorial: `rvest_example3.R` that continues previous work to extend the scraped dataset informing the tutorials for this class. However, this file is only included for class demonstration purposes. The dataset used in the `word-embeddings.R` example is the smaller, single-site scraped dataset used in previous tutorials.

## Goals
- Continue to extend scraping dataset in some form related to your project
- Pre-process text for text2vec
- Construct term co-occurance matrix
- Test word context/analogies 
