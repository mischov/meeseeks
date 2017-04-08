# Changelog

## v0.4.0 (2017-04-08)

### Enhancements

  * [Parse] Replace `html5ever_elixir` with `meeseeks_html5ever`
  * [Select] Allow CSS selector `:not()` to accept multiple selectors

### Fixes

  * [Parse] Move `Document.new/1` to `Parser.parse_tuple_tree/1`
  * [Select] Fix ordering in `Document.get_nodes/1` and `Accumulator.return/1` (for `Accumulator.All`)

## v0.3.1 (2017-04-03)

### Enhancements

  * [Extract] Add new `dataset` extractor that mimics the HTMLElement.dataset API
  * [Usability] Raise a better error when trying to select with a string instead of selectors
