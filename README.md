journal-scrapers
================

Journal scraper definitions for the ContentMine framework

### Definition

Scrapers are defined in JSON, using a schema that is currently evolving:

There can be two keys in the root object:

- ***url*** - a string-form regular expression specifying which URL(s) this scraper targets
- ***elements*** - a dictionary of elements to scrape

Elements are defined as key-value pairs, where the key is a description of the element, and the value is a dictionary of specifiers defining the element and its processing. Allowed keys in the specifier dictionary are:

<<<<<<< HEAD
- ***selector*** - an XPath or CSS selector targetting the element to be selected.
- ***attribute*** - a string specifying the attribute to extract from the selected element. **Optional** (omitting this key is equivalent to giving it a value of 'text').
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
