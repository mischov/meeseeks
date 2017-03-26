# Meeseeks

Meeseeks is an Elixir library for extracting data from HTML.

```elixir
iex> import Meeseeks.CSS
Meeseeks.CSS
iex> html = Tesla.get("https://news.ycombinator.com/").body
"..."
iex> for story <- Meeseeks.all(html, css("tr.athing")) do
       title = Meeseeks.one(story, css(".title a"))
       %{title: Meeseeks.text(title),
         url: Meeseeks.attr(title, "href")}
     end
[%{title: "...", url: "..."}, %{title: "...", url: "..."}, ...]
```
[API documentation](https://hexdocs.pm/meeseeks/Meeseeks.html) is available.

## Installation

Add Meeseeks to your `mix.exs`:

```elixir
defp deps do
  [
    {:meeseeks, "~> 0.3.0"}
  ]
end
```

Then run `mix get.deps`.

## Dependencies

Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via the [html5ever NIF](https://github.com/hansihe/html5ever_elixir).

Because html5ever is a Rust library, you will need to have the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

This dependency is necessary because there are no HTML5 spec compliant parsers written in Elixir/Erlang.

## Getting Started

### Parse

Start by parsing a source (HTML string or [`Meeseeks.TupleTree`](https://hexdocs.pm/meeseeks/Meeseeks.TupleTree.html)) into a [`Meeseeks.Document`](https://hexdocs.pm/meeseeks/Meeseeks.Document.html) so that it can be queried.

```elixir
iex> document = Meeseeks.parse("<div id=main><p>1</p><p>2</p><p>3</p></div>")
%Meeseeks.Document{...}
```

The selection functions accept an unparsed source, but parsing is expensive, so parse ahead of time when running multiple selections on the same document.

### Select

Next, use one of Meeseeks's two selection functions, `all` or `one`, to search for nodes. Both functions accept a queryable (a source, a document, or a [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html)) and one or more [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html)s.

`all` returns a list of results representing every node matching one of the provided selectors, while `one` returns a result representing the first node to match a selector (depth-first).

Use the `css` macro provided by [`Meeseeks.CSS`](https://hexdocs.pm/meeseeks/Meeseeks.CSS.html) to generate selectors.

```elixir
iex> import Meeseeks.CSS
Meeseeks.CSS
iex> result = Meeseeks.one(document, css("#main p"))
%Meeseeks.Result{ "<p>1</p>" }
```

### Extract

Retrieve information from the result with an extraction function.

The [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html) extraction functions are `attr`, `attrs`, `data`, `html`, `own_text`, `tag`, `text`, `tree`.

```elixir
iex> Meeseeks.tag(result)
"p"
iex> Meeseeks.text(result)
"1"
iex> Meeseeks.tree(result)
{"p", [], ["1"]}
```

## Custom Selectors

Meeseeks is designed to have extremely extensible selectors, and creating a custom selector is as easy as defining a struct that implements the [`Meeseeks.Selector`](https://hexdocs.pm/meeseeks/Meeseeks.Selector.html) behaviour.

```elixir
iex> defmodule CommentContainsSelector do
       use Meeseeks.Selector

       alias Meeseeks.Document

       defstruct value: ""

       def match?(selector, %Document.Comment{} = node, _document) do
         String.contains?(node.content, selector.value)
       end

       def match?(_selector, _node, _document) do
         false
       end
     end
{:module, ...}
iex> selector = %CommentContainsSelector{value: "TODO"}
%CommentContainsSelector{value: "TODO"}
iex> Meeseeks.one("<!-- TODO: Close vuln! -->", selector)
%Meeseeks.Result{ "<!-- TODO: Close vuln! -->" }
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
$ cd ecto
$ mix deps.get
$ mix test
```

### Building Docs

```
$ MIX_ENV=docs mix docs
```

## License

Meeseeks is licensed under the [MIT License](LICENSE)
