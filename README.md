# Meeseeks

[![Hex Version](https://img.shields.io/hexpm/v/meeseeks.svg?style=flat&color=%23714a94)](https://hex.pm/packages/meeseeks)
[![Hex Docs](https://img.shields.io/badge/hex-docs-%23714a94.svg?style=flat")](https://hexdocs.pm/meeseeks)
![tests](https://github.com/mischov/meeseeks/workflows/tests/badge.svg)

Meeseeks is an Elixir library for parsing and extracting data from HTML and XML with CSS or XPath selectors.

```elixir
import Meeseeks.CSS

html = HTTPoison.get!("https://news.ycombinator.com/").body

for story <- Meeseeks.all(html, css("tr.athing")) do
  title = Meeseeks.one(story, css(".title a"))

  %{
    title: Meeseeks.text(title),
    url: Meeseeks.attr(title, "href")
  }
end
#=> [%{title: "...", url: "..."}, %{title: "...", url: "..."}, ...]
```

## Features

- Friendly API
- Browser-grade HTML5 parser
- Permissive XML parser
- CSS and XPath selectors
- Supports custom selectors
- Helpers to extract data from selections

## Compatibility

Meeseeks requires a minimum combination of Elixir 1.6.0 and Erlang/OTP 20, and has been tested with a maximum combination of Elixir 1.10.0 and Erlang/OTP 22.0.

## Installation

Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via [meeseeks_html5ever](https://github.com/mischov/meeseeks_html5ever).

Because html5ever is a Rust library, you will need to have the Rust compiler [installed](https://www.rust-lang.org/tools/install) wherever Meeseeks is compiled.

Ensure Rust is installed, then add Meeseeks to your `mix.exs`:

```elixir
defp deps do
  [
    {:meeseeks, "~> 0.15.1"}
  ]
end
```

Finally, run `mix deps.get`.

## Getting Started

### Parse

Start by parsing a source (HTML/XML string or [`Meeseeks.TupleTree`](https://hexdocs.pm/meeseeks/Meeseeks.TupleTree.html)) into a [`Meeseeks.Document`](https://hexdocs.pm/meeseeks/Meeseeks.Document.html) so that it can be queried.

`Meeseeks.parse/1` parses the source as HTML, but `Meeseeks.parse/2` accepts a second argument of either `:html`, `:xml`, or `:tuple_tree` that specifies how the source is parsed.

```elixir
document = Meeseeks.parse("<div id=main><p>1</p><p>2</p><p>3</p></div>")
#=> #Meeseeks.Document<{...}>
```

The selection functions accept an unparsed source, parsing it as HTML, but parsing is expensive so parse ahead of time when running multiple selections on the same document.

### Select

Next, use one of Meeseeks's selection functions - `fetch_all`, `all`, `fetch_one`, or `one` - to search for nodes.

All these functions accept a queryable (a source, a document, or a [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html)), one or more [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html)s, and optionally an initial context.

`all` returns a (possibly empty) list of results representing every node matching one of the provided selectors, while `one` returns a result representing the first node to match a selector (depth-first) or nil if there is no match.

`fetch_all` and `fetch_one` work like `all` and `one` respectively, but wrap the result in `{:ok, ...}` if there is a match or return `{:error, %Meeseeks.Error{type: :select, reason: :no_match}}` if there is not.

To generate selectors, use the `css` macro provided by [`Meeseeks.CSS`](https://hexdocs.pm/meeseeks/Meeseeks.CSS.html) or the `xpath` macro provided by [`Meeseeks.XPath`](https://hexdocs.pm/meeseeks/Meeseeks.XPath.html).

```elixir
import Meeseeks.CSS
result = Meeseeks.one(document, css("#main p"))
#=> #Meeseeks.Result<{ <p>1</p> }>

import Meeseeks.XPath
result = Meeseeks.one(document, xpath("//*[@id='main']//p"))
#=> #Meeseeks.Result<{ <p>1</p> }>
```

### Extract

Retrieve information from the [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html) with an extractor.

The included extractors are `attr`, `attrs`, `data`, `dataset`, `html`, `own_text`, `tag`, `text`, `tree`.

```elixir
Meeseeks.tag(result)
#=> "p"
Meeseeks.text(result)
#=> "1"
Meeseeks.tree(result)
#=> {"p", [], ["1"]}
```

The extractors `html` and `tree` work on [`Meeseeks.Document`](https://hexdocs.pm/meeseeks/Meeseeks.Document.html)s in addition to [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html)s.

```elixir
Meeseeks.html(document)
#=> "<html><head></head><body><div id=\"main\"><p>1</p><p>2</p><p>3</p></div></body></html>"
```

## Guides

- [Meeseeks vs. Floki](guides/meeseeks_vs_floki.md)
- [CSS Selectors](guides/css_selectors.md)
- [XPath Selectors](guides/xpath_selectors.md)
- [Custom Selectors](guides/custom_selectors.md)
- [Deployment](guides/deployment.md)

## Contributing

If you are interested in contributing please read the [contribution guidelines](CONTRIBUTING.md).

## License

The MIT License (MIT)

Copyright (c) 2016-2020 Mischov (https://github.com/mischov)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
