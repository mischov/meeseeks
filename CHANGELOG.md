# Changelog

## v0.13.1 (2019-09-09)

### Enhancements

  * [Parse] Update to `meeseeks_html5ever v0.12.1`, which uses a dirty scheduler for the NIF instead of working asynchronously

## v0.13.0 (2019-09-08)

### Compatability

  * No longer support Elixir 1.4, Elixir 1.5, or Erlang/OTP 19 (minumum tested compatiblity is now Elixir 1.6 and Erlang/OTP 20)
  * Support Elixir 1.9 and Erlang/OTP 22

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.12.0`, which supports Erlang/OTP 22

## v0.12.0 (2019-07-25)

### Breaking

  * [Extract] `Meeseeks.html/1` now escapes problematic characters when encoding attribute values and text, so its output may be slightly different than before

### Fixes

  * [Extract] Always use double quotes and escape `&` and `"` when encoding attribute values with `Meeseeks.html/1`
  * [Extract] Escape `<`, `>`, and `&` when encoding text with `Meeseeks.html/1`

## v0.11.2 (2019-07-21)

### Fixes

  * [Select] Support escaped characters in CSS selector names, idents, and strings
  * [Select] Support Elixir-style unicode code points in CSS selector names, idents, and strings
  * [Select] Add better errors when parsing CSS selectors

## v0.11.1 (2019-06-28)

### Deprecations

  * [Parse] Deprecate parsing tuple trees with `parse/1`

### Enhancements

  * [Parse] Add `:tuple_tree` type to `parse/2`

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.11.1`, which returns a better error when provided with non-UTF-8 input
  * [Parse] Return parser errors if parsing an invalid tuple tree

## v0.11.0 (2019-02-28)

### Compatibility

  * No longer support Elixir 1.3 (minimum tested compatibility is now Elixir 1.4 and Erlang/OTP 19.3)
  * Support Elixir 1.8

### Enhancements

  * [Parse] Update to `meeseeks_html5ever v0.11.0`, which is faster and more memory efficient on Erlang/OTP 21

## v0.10.1 (2018-09-27)

  * [Meta] Test more Elixir+OTP combinations with Travis CI

## v0.10.0 (2018-07-06)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.10.0`, which supports OTP 21

## v0.9.5 (2018-06-23)

### Fixes

  * [Select] Remove optimization in `Select.handle_match` that could indirectly cause matches stored in the context for filtering to be prematurely cleared

## v0.9.4 (2018-06-22)

### Fixes

  * [Select] Fix error in how context was updated in `Select.filter_nodes`
  * [Select] Fix error in how context was updated in `XPath.Expr.Step.eval`
  * [Select] Fix error in how nodes were filtered in `XPath.Expr.Step.eval`
  * [Select] Include filters when transpiling absolute XPaths to root selectors

## v0.9.3 (2018-06-15)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.9.0`, which resolves a Dialyzer error

## v0.9.2 (2018-05-28)

### Enhancements

  * [Select] The `css` and `xpath` macros now accept vars

## v0.9.1 (2018-05-25)

### Fixes

  * [Select] Fix inconsistency in `Document.get_nodes/1`
  * [Select] Fix bug in `Document.get_nodes/2`, courtesy of @asonge
  * [Select] Fix various typespecs, courtesy of @asonge

## v0.9.0 (2018-05-15)

### Breaking

  * [Errors] Returned and raised errors throughout the project have been updated to use `Meeseeks.Error` instead of whatever assorted formats they were using before

### Enhancements

  * [Errors] Add `Meeseeks.Error`, a generic error struct implementing `Exception`
  * [Select] Add `Meeseeks.fetch_all` and `Meeseeks.fetch_one`

### Fixes

  * [Extract] Fix bug in `Meeseeks.html` when encoding element attribute values that contain double quotes

## v0.8.0 (2018-04-14)

### Enhancements

  * [Select] Most `Document` functions now raise if an unknown `node_id` is provided, when before they might have raised or might have handle the situation gracefully
  * [Select] Add `get_root_ids/1`, `get_node_ids/1`, and `fetch_node/2` to `Document`
  * [Select] Add `Document.delete_note/2`, courtesy of @willbarrett
  * [Readability] Remove Credo
  * [Readability] Add .formatters.exs and `mix format` project

### Fixes

  * [All] Fix various typespecs

## v0.7.7 (2018-02-08)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.8.1`, which supports OTP 20.2

## v0.7.6 (2017-09-24)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.8.0`, which removes panics related to calling `mark_script_already_started` and `get_template_contents`, and removes synchronous parsing, which did not correctly handle panics and broke the <1ms contract on first call
  * [Select] Update select functions to propagate parse errors

## v0.7.5 (2017-09-23)

### Fixes

  * [Parse] Update to `meeseeks_html5ever v0.7.0`, which fixes an erroneous panic related to calling `remove_from_parent` on a node with no parent

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
