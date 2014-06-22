journal-scrapers
================


Journal scraper definitions for the ContentMine framework.

This repo is a collection of ScraperJSON definitions targetting academic journals. They can be used to extract and download data from URLs of journal articles, such as:

- Title, author list, date
- Figures and their captions
- Fulltext PDF, HTML, XML, RDF
- Supplementary materials
- Reference lists

### Scraper collection status

All the scrapers in the collection are automatically tested daily as well as every time any scraper is changed. If the badge is green and says 'build | passing', all the scrapers are OK. If the badge is red and says 'build | failing', one or more of the scrapers has stopped working. You can click on the badge to see the test report, to see which scrapers are failing and how.

[![Build Status](https://secure.travis-ci.org/ContentMine/journal-scrapers.png?branch=master)][travis]

[travis]: http://travis-ci.org/ContentMine/journal-scrapers

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

### Usage

Currently these definitions can be used with the [quickscrape](http://github.com/ContentMine/quickscrape) tool.
