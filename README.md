# Meeseeks

[![Build Status](https://travis-ci.org/mischov/meeseeks.svg?branch=master)](https://travis-ci.org/mischov/meeseeks)

Meeseeks is an Elixir library for parsing and extracting data from HTML.

```elixir
import Meeseeks.CSS

html = Tesla.get("https://news.ycombinator.com/").body

for story <- Meeseeks.all(html, css("tr.athing")) do
  title = Meeseeks.one(story, css(".title a"))
  %{title: Meeseeks.text(title),
    url: Meeseeks.attr(title, "href")}
end
#=> [%{title: "...", url: "..."}, %{title: "...", url: "..."}, ...]
```
[API documentation](https://hexdocs.pm/meeseeks/Meeseeks.html) is available.

## Installation

Add Meeseeks to your `mix.exs`:

```elixir
defp deps do
  [
    {:meeseeks, "~> 0.4.1"}
  ]
end
```

Then run `mix get.deps`.

## Dependencies

Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via [meeseeks_html5ever](https://github.com/mischov/meeseeks_html5ever).

Because html5ever is a Rust library, you will need to have the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

This dependency is necessary because there are no HTML5 spec compliant parsers written in Elixir/Erlang.

## Getting Started

### Parse

Start by parsing a source (HTML string or [`Meeseeks.TupleTree`](https://hexdocs.pm/meeseeks/Meeseeks.TupleTree.html)) into a [`Meeseeks.Document`](https://hexdocs.pm/meeseeks/Meeseeks.Document.html) so that it can be queried.

```elixir
document = Meeseeks.parse("<div id=main><p>1</p><p>2</p><p>3</p></div>")
#=> #Meeseeks.Document<{...}>
```

The selection functions accept an unparsed source, but parsing is expensive, so parse ahead of time when running multiple selections on the same document.

### Select

Next, use one of Meeseeks's two selection functions, `all` or `one`, to search for nodes. Both functions accept a queryable (a source, a document, or a [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html)), one or more [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html)s, and optionally an initial context.

`all` returns a list of results representing every node matching one of the provided selectors, while `one` returns a result representing the first node to match a selector (depth-first).

Use the `css` macro provided by [`Meeseeks.CSS`](https://hexdocs.pm/meeseeks/Meeseeks.CSS.html) or the `xpath` macro provided by [`Meeseeks.XPath`](https://hexdocs.pm/meeseeks/Meeseeks.XPath.html) to generate selectors.

```elixir
import Meeseeks.CSS
result = Meeseeks.one(document, css("#main p"))
#=> #Meeseeks.Result<{ <p>1</p> }>

import Meeseeks.XPath
result = Meeseeks.one(document, xpath("//*[@id='main']//p"))
#=> #Meeseeks.Result<{ <p>1</p> }>
```

### Extract

Retrieve information from the result with an extraction function.

The [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html) extraction functions are `attr`, `attrs`, `data`, `dataset`, `html`, `own_text`, `tag`, `text`, `tree`.

```elixir
Meeseeks.tag(result)
#=> "p"
Meeseeks.text(result)
#=> "1"
Meeseeks.tree(result)
#=> {"p", [], ["1"]}
```

## Custom Selectors

Meeseeks is designed to have extremely extensible selectors, and creating a custom selector is as easy as defining a struct that implements the [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html) behaviour.

```elixir
defmodule CommentContainsSelector do
  use Meeseeks.Selector

  alias Meeseeks.Document

  defstruct value: ""

  def match(selector, %Document.Comment{} = node, _document, _context) do
    String.contains?(node.content, selector.value)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end

selector = %CommentContainsSelector{value: "TODO"}

Meeseeks.one("<!-- TODO: Close vuln! -->", selector)
#=> #Meeseeks.Result<{ <!-- TODO: Close vuln! --> }>
```

To learn more, check the documentation for [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html) and [`Meeseeks.Selector.Combinator`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.Combinator.html)

## Contribute

Contributions are very welcome, especially bug reports.

If submitting a bug report, please search open and closed issues first.

To make a pull request, fork the project, create a topic branch off of `master`, push your topic branch to your fork, and open a pull request.

If you're submitting a bug fix, please include a test or tests that would have caught the problem.

If you're submitting new features, please test and document as appropriate.

By submitting a patch, you agree to license your work under the license of this project.

### Running Tests

```
$ git clone https://github.com/mischov/meeseeks.git
$ cd meeseeks
$ mix deps.get
$ mix test
```

### Building Docs

```
$ MIX_ENV=docs mix docs
```

## License

Meeseeks is licensed under the [MIT License](LICENSE)
