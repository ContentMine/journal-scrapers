journal-scrapers
================

[travis]: http://travis-ci.org/ContentMine/journal-scrapers
[license]: https://creativecommons.org/publicdomain/zero/1.0/
[coverage]: https://coveralls.io/r/ContentMine/journal-scrapers

[![Build Status](http://img.shields.io/travis/ContentMine/journal-scrapers.svg)][travis]
[![Coverage](http://img.shields.io/coveralls/ContentMine/journal-scrapers.svg)][coverage]
[![License](http://img.shields.io/badge/license-CC0-blue.svg)][license]

Journal scraper definitions for the ContentMine framework.

This repo is a collection of ScraperJSON definitions targetting academic journals. They can be used to extract and download data from URLs of journal articles, such as:

- Title, author list, date
- Figures and their captions
- Fulltext PDF, HTML, XML, RDF
- Supplementary materials
- Reference lists

### Scraper collection status

All the scrapers in the collection are automatically tested daily as well as every time any scraper is changed. The tests work by having the expected results for a set of URLs stored, and randomly selecting one of those URLs to re-scrape. If the results match those expected the test passes. If the badge is green and says `build|passing`, all the scrapers are OK. If the badge is red and says `build|failing`, one or more of the scrapers has stopped working. You can click on the badge to see the test report, to see which scrapers are failing and how.

[![Build Status](http://img.shields.io/travis/ContentMine/journal-scrapers.svg)][travis]

How well the scrapers are covered by the tests is also checked. Coverage should be 100% - this means every element of every scraper is checked at least once in the testing. If coverage is below 100%, you can see exactly which parts of which scrapers are not covered by clicking the `coverage` badge below.

[![Coverage](http://img.shields.io/coveralls/ContentMine/journal-scrapers.svg)][coverage]

### ScraperJSON definitions

Scrapers are defined in JSON, using a schema called ScraperJSON which is currently evolving.

The current schema is described below.

There can be two keys in the root object:

- ***url*** - a string-form regular expression specifying which URL(s) this scraper targets
- ***elements*** - a dictionary of elements to scrape

Elements are defined as key-value pairs, where the key is a description of the element, and the value is a dictionary of specifiers defining the element and its processing. Allowed keys in the specifier dictionary are:

- ***selector*** - an XPath selector targetting the element to be selected.
- ***attribute*** - a string specifying the attribute to extract from the selected element. **Optional** (omitting this key is equivalent to giving it a value of `text`). In addition to html attributes there are two special attributes allowed:
    - `text` - extracts any plaintext inside the selected element
    - `html` - extracts the inner HTML of the selected element
- ***download*** - a boolean flag: true if the element is a URL to a resource that must be downloaded. **Optional** (omitting this key is equivalent to giving it a value of `false`).

Example:
```json
{
  "url": "plos.*\\.org",
  "elements": {
    "fulltext_pdf": {
      "selector": "//meta[@name='citation_pdf_url']",
      "attribute": "content",
      "download": true
    },
    "title": {
      "selector": "//meta[@name='citation_title']"
    }
  }
}
```

### Contributing scrapers

If your favourite publisher or journal is not covered by a scraper in our collection, we'd love you to submit a new scraper.

We ask that all contributions follow some simple rules that help us maintain a high-quality collection.

1. The scraper covers all [the data elements used in the ContentMine](wiki/data_collected_for_ContentMine).
2. You must submit a set of 5-10 test URLs.
3. It comes with a regression test ([which can be auto-generated](wiki/Generating-tests-for-your-scrapers)).
4. You agree to release the scraper definition and tests under the [Creative Commons Zero license](https://creativecommons.org/publicdomain/zero/1.0/).

### Usage

Currently these definitions can be used with the [quickscrape](http://github.com/ContentMine/quickscrape) tool.

### License

All scrapers are released under the [Creative Commons 0 (CC0)](https://creativecommons.org/publicdomain/zero/1.0/) license.
