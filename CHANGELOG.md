# Changelog

## v0.7.4 (2017-09-18)

### Enhancements

  * [Extract] Update extractors to propagate nil input

### Fixes

  * [Select] Fix CSS tokenization bug related to ab formulas

## v0.7.3 (2017-08-29)

### Fixes

  * [Select] Fix Elixir 1.5 related warnings

## v0.7.2 (2017-07-13)

### Enhancements

  * [Extract] Add `Document.html/1` and `Document.tree/1` extractors
  * [Extract] Update `Meeseeks.html/1` and `Meeseeks.tree/1` to accept a `Document`
  * [Extract] Update the extraction functions to return a better error when provided with invalid input

### Fixes

  * [Parse] Fix doctype parsing

## v0.7.1 (2017-06-29)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.6.1`, which supports OTP 20

## v0.7.0 (2017-06-05)

### Enhancements

  * [Parse] Update to `meeseeks_html5ever v0.6.0`, which supports parsing XML
  * [Parse] Add `Meeseeks.parse/2` which takes either `:html` or `:xml` as the second argument to specify how the source gets parsed
  * [Extract] Update `Meeseeks.data/1` to handle CDATA when parsing HTML

## v0.6.0 (2017-05-23)

### Breaking

  * [Select] Rename `Context.new/1` to `Context.prepare_for_selection/1`
  * [Select] Rename `Context.with_accumulator/2` to `Context.add_accumulator/2`

### Enhancements

  * [Parse] Update to `meeseeks_html5ever v0.5.0`
  * [Parse] Parse `Document.ProcessingInstruction` nodes from tuple-trees
  * [Select] Support `processing-instruction` functionality in `Meeseeks.XPath` (when possible)
  * [Select] Add a `Document.ProcessingInstruction` node type
  * [Select] Add `Select.select/3` and `Meeseeks.select/3`
  * [Select] Add `Context.ensure_accumulator!/1`

## v0.5.0 (2017-05-12)

### Breaking

  * [Select] Change the `Selector.match?/3` callback to `Selector.match/4`, which now takes a context and can return a `{boolean, context}` tuple in addition to returning a boolean.

### Enhancements

  * [Select] Add XPath selector support (see `Meeseeks.XPath`)
  * [Select] Add `Selector.filters/1` callback to the `Selector` behaviour and update selection to allow for filtering matches before proceeding
  * [Select] Add `Meeseeks.Context` to allow selectors and the selection process to store state
  * [Select] Add `Meeseeks.Accumulator` behaviour and update `Accumulator.{All, One}` to use it
  * [Select] Add `Node` and `Root` selectors
  * [Select] Add `Ancestors`, `AncestorsOrSelf`, `Children`, `Descendants`, `DescendantsOrSelf`, `NextSiblings`, `Parent`, `PreviousSiblings`, and `Self` selector combinators
  * [Select] Add `parent`, `ancestors`, and `previous_siblings` queries to `Document`

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.4.6`, which correctly parses namespaced elements and doesn't try to bring in `html5ever 0.16.0`
  * [Extract] Fix `html` extractor to add namespaces to elements
  * [Usability] Improve `Document` and `Result` opaque inspected values

## v0.4.1 (2017-04-10)

### Enhancements

  * [Meta] Add CI via Travis CI

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.4.4`, which permits Elixir 1.3
  * [Select] Fix CSS tokenization bug involving wildcard or pseudo-class descendants

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
