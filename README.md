# Meeseeks

[![Build Status](https://travis-ci.org/mischov/meeseeks.svg?branch=master)](https://travis-ci.org/mischov/meeseeks)
[![Meeseeks version](https://img.shields.io/hexpm/v/meeseeks.svg)](https://hex.pm/packages/meeseeks)

Meeseeks is an Elixir library for parsing and extracting data from HTML and XML with CSS or XPath selectors.

```elixir
import Meeseeks.CSS

html = HTTPoison.get!("https://news.ycombinator.com/").body

for story <- Meeseeks.all(html, css("tr.athing")) do
  title = Meeseeks.one(story, css(".title a"))
  %{title: Meeseeks.text(title),
    url: Meeseeks.attr(title, "href")}
end
#=> [%{title: "...", url: "..."}, %{title: "...", url: "..."}, ...]
```
See the [HexDocs](https://hexdocs.pm/meeseeks/Meeseeks.html) for additional documentation.

## Features

- Friendly API
- Browser-grade HTML5 parser
- Permissive XML parser
- CSS and XPath selectors
- Rich, extensible selector architecture
- Helpers to extract data from selections

## Why?

Meeseeks exists in the same space as an earlier library called Floki, so why was Meeseeks created and why would you use it instead of Floki?

#### Floki is a couple years older than Meeseeks, so why does Meeseeks even exist?

Meeseeks exists because Floki used to be unable to do what I needed.

When I started learning Elixir I reimplemented a small project I had written in another language. Part of that project involved extracting data from HTML, and unbeknownst to me some of the HTML I needed to extract data from was malformed.

This had never been a problem before because the HTML parser I was using in the other language was HTML5 spec compliant and handled the malformed HTML just as well as a browser. Unfortunately for me, Floki used (and still uses by default) the `:mochiweb_html` parser which is nowhere near HTML5 spec compliant, and just silently dropped the data I needed when parsing.

Meeseeks started out as an attempt to write an HTML5 spec compliant parser in Elixir (spoiler: it's really hard), then switched to using Mozilla's [html5ever](https://github.com/servo/html5ever) via Rustler after [Hans](https://github.com/hansihe) wrote `html5ever_elixir`.

Floki gained optional support for using `html5ever_elixir` as its parser around the same time, but it still used `:mochiweb_html` (which doesn't require Rust to be part of the build process) by default and I released Meeseeks as a safer alternative.

#### Why should I use Meeseeks instead of Floki?

When Meeseeks was released it came with a safer default HTML parser, a more complete collection of CSS selectors, and a more extensible selector architecture than Floki.

Since then Meeseeks has been further expanded with functionality Floki just doesn't have, such as an XML parser and XPath selectors.

It won't matter to most users, but the selection architecture is much richer than Floki's, and permits the creation all kinds of interesting custom, stateful selectors (in fact, both the CSS and XPath selector strings compile down to the same selector structs that anybody can define).

What probably will matter more to users is the friendly API, extensive documentation, and the attention to the details of usability seen in such places as the custom formatting for result structs (`#Meeseeks.Result<{ <p>1</p> }>`) and the descriptive errors.

#### Is Floki ever a better choice than Meeseeks?

Yes, there are two main cases when Floki is clearly a better choice than Meeseeks.

Firstly, if you absolutely can't include Rust in your build process AND you know that the HTML you'll be working with is well-formed and won't require an HTML5 spec compliant parser then using Floki with the `:mochiweb_html` parser is a reasonable choice.

However, if you have any doubts about the HTML you'll be parsing you should probably figure out a way to use a better parser because using `:mochiweb_html` in that situation may be a timebomb.

Secondly, if you want to make updates to an HTML document Floki provides facilities to do so while Meeseeks, which is entirely focused on selecting and extracting data, does not.

#### How does performance compare between Floki and Meeseeks?

Performance is similar enough between the two that it's probably not worth choosing one over the other for that reason.

For details and benchmarks, see [Meeseeks vs. Floki Performance](https://github.com/mischov/meeseeks_floki_bench).

## Compatibility

Meeseeks requires a minimum combination of Elixir 1.6.0 and Erlang/OTP 20, and has been tested with a maximum combination of Elixir 1.9.0 and Erlang/OTP 22.0.

## Dependencies

Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via [meeseeks_html5ever](https://github.com/mischov/meeseeks_html5ever).

Because html5ever is a Rust library, you will need to have the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html).

This dependency is necessary because there are no HTML5 spec compliant parsers written in Elixir/Erlang.

#### Deploying to Heroku?

Most Heroku buildpacks for Elixir do not come with Rust installed; you will need to:

- Add a Rust buildpack to your app, setting it to run before Elixir; and
- Add a `RustConfig` file to your project's root directory, with `RUST_SKIP_BUILD=1` set.

For example:
```bash
heroku buildpacks:add -i 1 https://github.com/emk/heroku-buildpack-rust.git
echo "RUST_SKIP_BUILD=1" > RustConfig
```

## Installation

Ensure Rust is installed, then add Meeseeks to your `mix.exs`:

```elixir
defp deps do
  [
    {:meeseeks, "~> 0.13.0"}
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

Retrieve information from the [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html) with an extraction function.

The extraction functions are `attr`, `attrs`, `data`, `dataset`, `html`, `own_text`, `tag`, `text`, `tree`.

```elixir
Meeseeks.tag(result)
#=> "p"
Meeseeks.text(result)
#=> "1"
Meeseeks.tree(result)
#=> {"p", [], ["1"]}
```

The extraction functions `html` and `tree` work on [`Meeseeks.Document`](https://hexdocs.pm/meeseeks/Meeseeks.Document.html)s in addition to [`Meeseeks.Result`](https://hexdocs.pm/meeseeks/Meeseeks.Result.html)s.

```elixir
Meeseeks.html(document)
#=> "<html><head></head><body><div id=\"main\"><p>1</p><p>2</p><p>3</p></div></body></html>"
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

Before submitting a PR, please run `mix format`.

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
