doks
====

A configurable, bring-your-own-template documentation generator aimed for user and developer documentation based on source code.

Basic Use
=========

You can either use `doks` as a command line tool (`npm install -g doks`) or programmatically, with `var Parser = require('doks').Parser`.

If you choose to run it from the command line, the best option is to create a `doks.json` file in the root of your repository, with a structure like this (taken from [our doks.json](https://github.com/kellyirc/doks/blob/master/doks.json)):

```json
{
  "language": "coffee",
  "glob": "lib/parser.coffee",
  "arrayTags": [
    "supports",
    "param"
  ]
}
```

Languages supported
-------------------
* `coffee` - coffeescript style comments, using `###` as the start and end, or `###*` as the start of the block, and `###` as the end.
* `js` - js/javadoc style comments, using `/**` and `*/` as the start and end tokens, respectively.
* `escapedCoffee` - js-style comments, escaped for coffeescript usage. Tokens are the same as `js`-style comments, except they have a backtick (`) on the left of the opening token, and the right of the closing token.

Then just run `doks` and it will generate your documentation, based on your source code comments.

Whether you use the command line tool or run it yourself, the supported options are [available here](http://kellyirc.github.io/doks/#!/TagParser/Option).

Themes
======

Themes are very flexible by design. You could build one from scratch, or work based off of the existing efforts put forth.

Themes should generally have a similar structure, like so:

```
core
vendor
views
config.json   // this is required
favicon.ico   // this should be the default doks favicon.ico
index.html    // this is required
```

A config.json should be structured like so:
```json
{
  "keys": {
    "category": "package",
    "mainType": "category",
    "subType": "name"
  },
  "options": {
    "page": {
      "pageName": "Doks",
      "favicon": "favicon.ico",
      "showGitHubBadges": true
    },
    "nav": {
      "categorySeparate": false,
      "mainTypeRight": false,
      "useSearchBar": true
    },
    "content": {
      "showFileLabels": true,
      "sourceLink": "https://github.com/kellyirc/doks/tree/master/%filePath#L%lineNumber-L%endLineNumber"
    }
  }
}
```

However, the only required key here is `options` - doks uses that to merge user configuration into the theme configuration. Everything else is determined by the theme.
