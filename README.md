# Meeseeks

Meeseeks is an Elixir library for extracting data from HTML.

```elixir
# Fetch HTML with your preferred library
html = Tesla.get("https://news.ycombinator.com/").body

# Select stories and return a map containing the title and url of each
for story <- Meeseeks.all(html, "tr.athing") do
  title_a = Meeseeks.one(story, ".title a")
  %{:title => Meeseeks.text(title_a),
    :url => Meeseeks.attr(title_a, "href")}
end

#=> [%{:title => "...", :url => "..."}, %{:title => "...", :url => "..."}, ...]
```

## Installation

Add Meeseeks to your `mix.exs`:

```elixir
defp deps do
  [
    {:meeseeks, "~> 0.1.0"},
  ]
end
```

Then run `mix get.deps`.

## Dependencies

Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via [html5ever_elixir](https://github.com/hansihe/html5ever_elixir).

Because html5ever is a Rust library, you will need to have the Rust compiler [installed](https://www.rust-lang.org/en-US/install.html) in order to use Meeseeks.

This is necessary because there are no HTML5 spec compliant parsers in Erlang/Elixir. The mochiweb_html library is decent, but can have problems parsing malformed HTML correctly, which leads to weirdness I would just as soon avoid.

## Overview

### Parsing

Meeseeks parses a source (HTML string or tuple-tree) into a `Document`. A `Document` is just an easily queriable view of the source HTML with the nodes assigned ids and the parent-child relationships made explicit.

```elixir
# Can parse html as a string
Meeseeks.parse("<div id=main><p>Hello, Github!</p></div>")
#=> %Meeseeks.Document{...}

# Or as a tuple-tree
Meeseeks.parse({"div", [{"id", "main"}], [{"p", [], ["Hello, Github!"]}]})
#=> %Meeseeks.Document{...}
```

The selection functions `all` and `one` will accept unparsed HTML, but parsing is expensive, so parse ahead of time if you are planning to run multiple selections on the same `Document`.

### Selecting

Meeseeks has two selection functions, `all` and `one`, which both accept a queryable (a source, a `Document`, or a `Result`) and selectors as arguments.

`all` returns a list of `Result`s representing every node that matches a selector, while `one` returns a `Result` representing the first node that matches a selector (depth-first).

A `Result` is a node id packaged with the `Document` for which that id is valid.

```elixir
html = "<div id=main><p>1</p><p>2</p><p>3</p></div>"
document = Meeseeks.parse(html)

# Selection functions will accept raw html as a source, first parsing it
Meeseeks.all(html, "#main p")
#=> [%Meeseeks.Result{...}, %Meeseeks.Result{...}, %Meeseeks.Result{...}]

# Selection functions will also accept a `Document` as a source
Meeseeks.one(document, "#main p")
#=> %Meeseeks.Result{...}

# Selection functions accept a `Result` as a source
Meeseeks.one(html, "#main") |> Meeseeks.all("p")
#=> [%Meeseeks.Result{...}, %Meeseeks.Result{...}, %Meeseeks.Result{...}]
```

For an overview of valid selectors, see the [selector syntax](#selector-syntax)

### Extracting

In order to transform a `Result` into useful data, you need to use an extraction function.

The provided extraction functions are `tag`, `attrs`, `attr`, `tree`, `text`, and `data`.

```elixir
html = "<div id=main><p>1</p><p>2</p><p>3</p></div>"
result = Meeseeks.one(html, "#main")

# Maybe you want your result's tag
Meeseeks.tag(result)
#=> "div"

# Or a specific attribute from your result
Meeseeks.attr(result, "id")
#=> "main"

# Or a tuple tree representing your result and its children
Meeseeks.tree(result)
#=> {"div", [{"id", "main"}], [{"p", [], ["1"]}, {"p", [], ["2"]}, ...]}

# Or the joined text of a node and its children
Meeseeks.text(result)
#=> "123"
```

## Selector Syntax

The selector syntax is based on (a subset of) CSS selectors.

| Pattern | Example | Notes |
| --- | --- | --- |
| **Simple Selectors** | --- | --- |
| `*` | `*` | Matches any. Valid for `ns` or `tag` |
| `tag` | `div` | |
| `ns|tag` | `<foo:div>` | |
| `#id` | `div#bar`, `#bar` | |
| `.class` | `div.baz`, `.baz` | |
| `[attr]` | `a[href]`, `[lang]` | |
| `[^attrPrefix]` | `div[^data-]` | |
| `[attr=val]` | `a[ref=nofollow]` | |
| `[attr="val"]` | `a[rel="nofollow"]` | |
| `[attr^=valPrefix]` | `a[href^=https:]` | |
| `[attr$=valSuffix]` | `img[src$=.png]` | |
| `[attr*=valContaining]` | `a[href*=admin]` | |
| &#8203; | | |
| **Pseudo Selectors** | --- | --- |
| `:nth-child(n)` | `p:nth-child(2)` | n can be 1.., or even, or odd |
| `:first-child` | `li:first-child` | |
| `:last-child` | `tr:last-child` | |
| &#8203; | | |
| **Combinators** | --- | --- |
| `X Y` | `div.header .logo` | `Y` descendant of `X` |
| `X > Y` | `ol > li` | `Y` child of `X` |
| `X + Y` | `div + p` | `Y` is sibling directly after `X` |
| `X ~ Y` | `div ~ p` | `Y` is any sibling after `X` |
| `X, Y, Z` | `button.standard, button.alert` | Matches `X`, `Y`, or `Z` |
