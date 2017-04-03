defmodule Meeseeks do

  alias Meeseeks.{Document, Parser, Result, Select, Selector, TupleTree}

  @moduledoc """
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

  ## Dependencies

  Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via
  the [html5ever NIF](https://github.com/hansihe/html5ever_elixir).

  Because html5ever is a Rust library, you will need to have the Rust
  compiler [installed](https://www.rust-lang.org/en-US/install.html).

  This dependency is necessary because there are no HTML5 spec compliant
  parsers written in Elixir/Erlang.

  ## Getting Started

  ### Parse

  Start by parsing a source (HTML string or `Meeseeks.TupleTree`) into a
  `Meeseeks.Document` so that it can be queried.

  ```elixir
  iex> document = Meeseeks.parse("<div id=main><p>1</p><p>2</p><p>3</p></div>")
  %Meeseeks.Document{...}
  ```

  The selection functions accept an unparsed source, but parsing is
  expensive, so parse ahead of time when running multiple selections on
  the same document.

  ### Select

  Next, use one of Meeseeks's two selection functions, `all` or `one`, to
  search for nodes. Both functions accept a queryable (a source, a
  document, or a `Meeseeks.Result`) and one or more
  `Meeseeks.Selector`s.

  `all` returns a list of results representing every node matching one of
  the provided selectors, while `one` returns a result representing the
  first node to match a selector (depth-first).

  Use the `css` macro provided by `Meeseeks.CSS` to generate selectors.

  ```elixir
  iex> import Meeseeks.CSS
  Meeseeks.CSS
  iex> result = Meeseeks.one(document, css("#main p"))
  %Meeseeks.Result{ "<p>1</p>" }
  ```

  ### Extract

  Retrieve information from the result with an extraction function.

  The `Meeseeks.Result` extraction functions are `attr`, `attrs`, `data`,
  `dataset`, `html`, `own_text`, `tag`, `text`, `tree`.

  ```elixir
  iex> Meeseeks.tag(result)
  "p"
  iex> Meeseeks.text(result)
  "1"
  iex> Meeseeks.tree(result)
  {"p", [], ["1"]}
  ```

  ## Custom Selectors

  Meeseeks is designed to have extremely extensible selectors, and creating
  a custom selector is as easy as defining a struct that implements the
  `Meeseeks.Selector` behaviour.

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

  To learn more, check the documentation for `Meeseeks.Selector` and
  `Meeseeks.Selector.Combinator`
  """

  @type source :: String.t | TupleTree.t
  @type queryable :: source | Document.t | Result.t
  @type selectors :: Selector.t | [Selector.t]

  # Parse

  @doc """
  Parses an HTML string or `Meeseeks.TupleTree` into a `Meeseeks.Document`.

  ## Examples

  ```elixir
  iex> Meeseeks.parse("<div id=main><p>Hello, Meeseeks!</p></div>")
  %Meeseeks.Document{...}

  iex> Meeseeks.parse({"div", [{"id", "main"}], [{"p", [], ["Hello, Meeseeks!"]}]})
  %Meeseeks.Document{...}
  ```
  """
  @spec parse(source) :: Document.t
  def parse(source) do
    Parser.parse(source)
  end

  # Select

  @doc """
  Returns a `Result` for each node in the queryable matching a selector.

  ## Examples

  ```elixir
  iex> Meeseeks.all("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p"))
  [%Meeseeks.Result{ "<p>1</p>" }, %Meeseeks.Result{ "<p>2</p>" },
   %Meeseeks.Result{ "<p>3</p>" }]
  ```
  """
  @spec all(queryable, selectors) :: [Result.t]
  def all(%Document{} = queryable, selectors) do
    Select.all(queryable, selectors)
  end

  def all(%Result{} = queryable, selectors) do
    Select.all(queryable, selectors)
  end

  def all(source, selectors) do
    source
    |> parse()
    |> Select.all(selectors)
  end

  @doc """
  Returns a `Result` for the first node in the queryable (depth-first) matching a selector.

  ## Examples

  ```elixir
  iex> Meeseeks.one("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p"))
  %Meeseeks.Result{ "<p>1</p>" }
  ```
  """
  @spec one(queryable, selectors) :: Result.t
  def one(%Document{} = queryable, selectors) do
    Select.one(queryable, selectors)
  end

  def one(%Result{} = queryable, selectors) do
    Select.one(queryable, selectors)
  end

  def one(source, selectors) do
    source
    |> parse()
    |> Select.one(selectors)
  end

  # Extract

  @doc """
  Returns the value for attribute in result, or nil if there isn't one.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.attr(result, "id")
  "example"
  ```
  """
  @spec attr(Result.t, String.t) :: String.t | nil
  def attr(result, attribute) do
    Result.attr(result, attribute)
  end

  @doc """
  Returns the result's attributes list, which may be empty, or nil if
  result represents a node without attributes.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.attrs(result)
  [{"id", "example"}]
  ```
  """
  @spec attrs(Result.t) :: [{String.t, String.t}] | nil
  def attrs(result) do
    Result.attrs(result)
  end

  @doc """
  Returns the combined data of result or result's children, which may be an
  empty string.

  ## Examples

  ```elixir
  iex> result1 = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.data(result1)
  ""

  iex> result2 = Meeseeks.one("<script id=example>Hi</script>", css("#example"))
  %Meeseeks.Result{ "<script id=\\"example\\">Hi</script>" }
  iex> Meeseeks.data(result2)
  "Hi"
  ```
  """
  @spec data(Result.t) :: String.t
  def data(result) do
    Result.data(result)
  end

  @doc """
  Returns a map of result's data attributes, or nil if result represents a
  node without attributes.

  Behaves like HTMLElement.dataset; only valid data attributes are included,
  and attribute names have "data-" removed and are converted to camelCase.

  See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example data-x-val=1 data-y-val=2></div>", css("#example"))
  %Meeseeks.Result{ "<div id=\"example\" data-x-val=\"1\" data-y-val=\"2\"></div>" }
  iex> Meeseeks.dataset(result)
  %{"xVal" => "1", "yVal" => "2"}
  ```
  """
  @spec dataset(Result.t) :: %{optional(String.t) => String.t} | nil
  def dataset(result) do
    Result.dataset(result)
  end

  @doc """
  Returns the combined HTML of result and its descendants.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.html(result)
  "<div id=\\"example\\">Hi</div>"
  ```
  """
  @spec html(Result.t) :: String.t
  def html(result) do
    Result.html(result)
  end

  @doc """
  Returns the combined text of result or result's children, which may be an
  empty string.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div>Hello, <b>World!</b></div>", css("div"))
  %Meeseeks.Result{ "<div>Hello, <b>World!</b></div>" }
  iex> Meeseeks.own_text(result)
  "Hello,"
  ```
  """
  @spec own_text(Result.t) :: String.t
  def own_text(result) do
    Result.own_text(result)
  end

  @doc """
  Returns result's tag, or nil if result represents a node without a tag.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.tag(result)
  "div"
  ```
  """
  @spec tag(Result.t) :: String.t | nil
  def tag(result) do
    Result.tag(result)
  end

  @doc """
  Returns the combined text of result or result's descendants, which may be
  an empty string.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div>Hello, <b>World!</b></div>", css("div"))
  %Meeseeks.Result{ "<div>Hello, <b>World!</b></div>" }
  iex> Meeseeks.own_text(result)
  "Hello, World!"
  ```
  """
  @spec text(Result.t) :: String.t
  def text(result) do
    Result.text(result)
  end

  @doc """
  Returns a `Meeseeks.TupleTree` of result and its descendants.

  ## Examples

  ```elixir
  iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
  %Meeseeks.Result{ "<div id=\\"example\\">Hi</div>" }
  iex> Meeseeks.tree(result)
  {"div", [{"id", "example"}], ["Hi"]}
  ```
  """
  @spec tree(Result.t) :: TupleTree.node_t
  def tree(result) do
    Result.tree(result)
  end
end
