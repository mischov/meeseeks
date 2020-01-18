# XPath Selectors

`Meeseeks.XPath` supports a majority of XPath 1.0 syntax with a few notable exceptions.

### No top-level filter expressions

Due to the way selection works, top-level filter expressions like `xpath("(//ol|//ul)[2]")`, which would select the second list element in the document, are particularly difficult to implement. An error will be raised if you try to use the above or any other top-level filter expression.

To do the above try something like:

```elixir
Meeseeks.all(doc, xpath("ol|ul")) |> Enum.at(1)
```

All other filter expressions, like `xpath("//div[2]")`, are valid.

### No attribute steps outside of predicates

Due both to how selection works and how attributes are represented in documents (stored as part of an element, rather than as a separate node) there is no easy way to implement attribute selection, and use of attributes steps are prohibited outside of predicates and will raise an error.

For example, `xpath("//p[@class]")` which returns elements with class attributes is allowed, but `xpath("//p/@class")` which would return the class attributes themselves is prohibited.

To extract a selected element's attribute use the `attr` extractor.

```elixir
Meeseeks.all(doc, xpath("//p[@class]"))
|> Enum.map(&Meeseeks.attr(&1, "class"))
```

### No support for variable references

Variable references are not currently supported, meaning expression like `xpath("*[position()=$p]")` are invalid and will raise an error.

To do the above try something like:

```elixir
p = 2
xpath("*[position()=" <> Integer.to_string(p) <> "]")
```

### No support for id(), lang(), or translate() functions

These three functions from the core functions library are not currently supported. A runtime error will be raised should they attempt to be used.

### Namespace prefixes are not resolved to namespace uris

If you want to find a namespace, search for the namespace prefix of node, not the expanded namespace-uri. `xpath("*[namespace-uri()='example']")`, not `xpath("*[namespace-uri()='https://example.com/ns']")`

### HTML5 doesn't support processing instructions

Because in HTML5 processing instructions as are parsed as comments, trying to select a processing instruction will not work as expected if you are using `meeseeks_html5ever`'s html parser. To select a processing instruction when parsing with `meeseeks_html5ever`'s html parser, search for comment nodes.

If you've parsed a tuple-tree that had a `{:pi, _}` or `{:pi, _, _}` node, selecting processing instructions should work as expected, though if the tuple-tree is the result of parsing with `:mochiweb_html`, the data might be slightly mangled due to `:mochiweb_html`'s rather suspect decision to parse the data of all processing instructions except `<?php .. ?>` as attributes.
