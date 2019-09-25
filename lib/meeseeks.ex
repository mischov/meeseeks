defmodule Meeseeks do
  alias Meeseeks.{Context, Document, Error, Parser, Result, Select, Selector, TupleTree}

  @moduledoc """
  Meeseeks is an Elixir library for parsing and extracting data from HTML and
  XML with CSS or XPath selectors.

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

  ## Features

  - Friendly API
  - Browser-grade HTML5 parser
  - Permissive XML parser
  - CSS and XPath selectors
  - Rich, extensible selector architecture
  - Helpers to extract data from selections

  ## Why?

  Meeseeks exists in the same space as an earlier library called Floki, so
  why was Meeseeks created and why would you use it instead of Floki?

  #### Floki is a couple years older than Meeseeks, so why does Meeseeks even exist?

  Meeseeks exists because Floki used to be unable to do what I needed.

  When I started learning Elixir I reimplemented a small project I had
  written in another language. Part of that project involved extracting data
  from HTML, and unbeknownst to me some of the HTML I needed to extract data
  from was malformed.

  This had never been a problem before because the HTML parser I was using
  in the other language was HTML5 spec compliant and handled the malformed
  HTML just as well as a browser. Unfortunately for me, Floki used (and still
  uses by default) the `:mochiweb_html` parser which is nowhere near HTML5
  spec compliant, and just silently dropped the data I needed when parsing.

  Meeseeks started out as an attempt to write an HTML5 spec compliant parser
  in Elixir (spoiler: it's really hard), then switched to using Mozilla's
  [html5ever](https://github.com/servo/html5ever) via Rustler after
  [Hans](https://github.com/hansihe) wrote `html5ever_elixir`.

  Floki gained optional support for using `html5ever_elixir` as its parser
  around the same time, but it still used `:mochiweb_html` (which doesn't
  require Rust to be part of the build process) by default and I released
  Meeseeks as a safer alternative.

  #### Why should I use Meeseeks instead of Floki?

  When Meeseeks was released it came with a safer default HTML parser, a more
  complete collection of CSS selectors, and a more extensible selector
  architecture than Floki.

  Since then Meeseeks has been further expanded with functionality Floki
  just doesn't have, such as an XML parser and XPath selectors.

  It won't matter to most users, but the selection architecture is much
  richer than Floki's, and permits the creation all kinds of interesting
  custom, stateful selectors (in fact, both the CSS and XPath selector
  strings compile down to the same selector structs that anybody can define).

  What probably will matter more to users is the friendly API, extensive
  documentation, and the attention to the details of usability seen in such
  places as the custom formatting for result structs
  (`#Meeseeks.Result<{ <p>1</p> }>`) and the descriptive errors.

  #### Is Floki ever a better choice than Meeseeks?

  Yes, there are two main cases when Floki is clearly a better choice than
  Meeseeks.

  Firstly, if you absolutely can't include Rust in your build process AND you
  know that the HTML you'll be working with is well-formed and won't require
  an HTML5 spec compliant parser then using Floki with the `:mochiweb_html`
  parser is a reasonable choice.

  However, if you have any doubts about the HTML you'll be parsing you should
  probably figure out a way to use a better parser because using
  `:mochiweb_html` in that situation may be a timebomb.

  Secondly, if you want to make updates to an HTML document then Floki
  provides facilities to do so while Meeseeks, which is entirely focused on
  selecting and extracting data, does not.

  #### How does performance compare between Floki and Meeseeks?

  Performance is similar enough between the two that it's probably not worth
  choosing one over the other for that reason.

  For details and benchmarks, see [Meeseeks vs. Floki Performance
  ](https://github.com/mischov/meeseeks_floki_bench).

  ## Compatibility

  Meeseeks is tested with a minimum combination of Elixir 1.4.0 and
  Erlang/OTP 19.3, and a maximum combination of Elixir 1.8.1 and
  Erlang/OTP 21.0.

  ## Dependencies

  Meeseeks depends on [html5ever](https://github.com/servo/html5ever) via
  [meeseeks_html5ever](https://github.com/mischov/meeseeks_html5ever).

  Because html5ever is a Rust library, you will need to have the Rust
  compiler [installed](https://www.rust-lang.org/en-US/install.html).

  This dependency is necessary because there are no HTML5 spec compliant
  parsers written in Elixir/Erlang.

  ## Getting Started

  ### Parse

  Start by parsing a source (HTML/XML string or `Meeseeks.TupleTree`) into
  a `Meeseeks.Document` so that it can be queried.

  `Meeseeks.parse/1` parses the source as HTML, but `Meeseeks.parse/2`
  accepts a second argument of either `:html` or `:xml` that specifies how
  the source is parsed.

  ```elixir
  document = Meeseeks.parse("<div id=main><p>1</p><p>2</p><p>3</p></div>")
  #=> Meeseeks.Document<{...}>
  ```

  The selection functions accept an unparsed source, parsing it as HTML, but
  parsing is expensive so parse ahead of time when running multiple
  selections on the same document.

  ### Select

  Next, use one of Meeseeks's selection functions - `fetch_all`, `all`,
  `fetch_one`, or `one` - to search for nodes.

  All these functions accept a queryable (a source, a document, or a
  `Meeseeks.Result`), one or more `Meeseeks.Selector`s, and optionally an
  initial context.

  `all` returns a (possibly empty) list of results representing every node
  matching one of the provided selectors, while `one` returns a result
  representing the first node to match a selector (depth-first) or nil if
  there is no match.

  `fetch_all` and `fetch_one` work like `all` and `one` respectively, but
  wrap the result in `{:ok, ...}` if there is a match or return
  `{:error, %Meeseeks.Error{type: :select, reason: :no_match}}` if there is
  not.

  To generate selectors, use the `css` macro provided by `Meeseeks.CSS` or
  the `xpath` macro provided by `Meeseeks.XPath`.

  ```elixir
  import Meeseeks.CSS
  result = Meeseeks.one(document, css("#main p"))
  #=> #Meeseeks.Result<{ <p>1</p> }>

  import Meeseeks.XPath
  result = Meeseeks.one(document, xpath("//*[@id='main']//p"))
  #=> #Meeseeks.Result<{ <p>1</p> }>
  ```

  ### Extract

  Retrieve information from the `Meeseeks.Result` with an extraction
  function.

  The extraction functions are `attr`, `attrs`, `data`, `dataset`, `html`,
  `own_text`, `tag`, `text`, `tree`.

  ```elixir
  Meeseeks.tag(result)
  #=> "p"
  Meeseeks.text(result)
  #=> "1"
  Meeseeks.tree(result)
  #=> {"p", [], ["1"]}
  ```

  The extraction functions `html` and `tree` work on `Meeseeks.Document`s in
  addition to `Meeseeks.Result`s.

  ```elixir
  Meeseeks.html(document)
  #=> "<html><head></head><body><div id=\\"main\\"><p>1</p><p>2</p><p>3</p></div></body></html>"
  ```

  ## Custom Selectors

  Meeseeks is designed to have extremely extensible selectors, and creating
  a custom selector is as easy as defining a struct that implements the
  `Meeseeks.Selector` behaviour.

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

  To learn more, check the documentation for `Meeseeks.Selector` and
  `Meeseeks.Selector.Combinator`
  """

  @type queryable :: Parser.source() | Document.t() | Result.t()
  @type extractable :: Document.t() | Result.t() | nil
  @type selectors :: Selector.t() | [Selector.t()]

  # Parse

  @doc """
  Parses a string or `Meeseeks.TupleTree` into a `Meeseeks.Document`.

  `parse/1` parses as HTML, while `parse/2` accepts a second argument of
  either `:html`, `:xml`, or `tuple_tree` that specifies how the source is
  parsed.

  ## Examples

      iex> Meeseeks.parse("<div id=main><p>Hello, Meeseeks!</p></div>")
      #Meeseeks.Document<{...}>

      iex> Meeseeks.parse("<book><author>GGK</author></book>", :xml)
      #Meeseeks.Document<{...}>

      iex> Meeseeks.parse({"div", [{"id", "main"}], [{"p", [], ["Hello, Meeseeks!"]}]}, :tuple_tree)
      #Meeseeks.Document<{...}>
  """
  @spec parse(Parser.source()) :: Document.t() | {:error, Error.t()}
  def parse(source) do
    Parser.parse(source)
  end

  @spec parse(Parser.source(), Parser.type()) :: Document.t() | {:error, Error.t()}
  def parse(source, parser) do
    Parser.parse(source, parser)
  end

  # Select

  @doc """
  Returns `{:ok, [Result, ...]}` if one of more nodes in the queryable match
  a selector, or `{:error, %Meeseeks.Error{type: :select, reason: :no_match}}`
  if none do.

  Optionally accepts a `Meeseeks.Context` map.

  Parses the source if it is not a `Meeseeks.Document` or `Meeseeks.Result`,
  and may return `{:error, %Meeseeks.Error{type: parser}` if there is a parse
  error.

  If multiple selections are being ran on the same unparsed source, parse
  first to avoid unnecessary computation.

  ## Examples

      iex> import Meeseeks.CSS
      iex> Meeseeks.fetch_all("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p")) |> elem(1) |> List.first()
      #Meeseeks.Result<{ <p>1</p> }>
  """
  @spec fetch_all(queryable, selectors) :: {:ok, [Result.t()]} | {:error, Error.t()}
  def fetch_all(queryable, selectors) do
    fetch_all(queryable, selectors, %{})
  end

  @spec fetch_all(queryable, selectors, Context.t()) :: {:ok, [Result.t()]} | {:error, Error.t()}
  def fetch_all(queryable, selectors, context)

  def fetch_all({:error, _} = error, _selectors, _context), do: error

  def fetch_all(%Document{} = queryable, selectors, context) do
    Select.fetch_all(queryable, selectors, context)
  end

  def fetch_all(%Result{} = queryable, selectors, context) do
    Select.fetch_all(queryable, selectors, context)
  end

  def fetch_all(source, selectors, context) do
    case parse(source) do
      {:error, reason} -> {:error, reason}
      document -> Select.fetch_all(document, selectors, context)
    end
  end

  @doc """
  Returns `[Result, ...]` if one or more nodes in the queryable match a
  selector, or `[]` if none do.

  Optionally accepts a `Meeseeks.Context` map.

  Parses the source if it is not a `Meeseeks.Document` or `Meeseeks.Result`,
  and may return `{:error, %Meeseeks.Error{type: parser}` if there is a parse
  error.

  If multiple selections are being ran on the same unparsed source, parse
  first to avoid unnecessary computation.

  ## Examples

      iex> import Meeseeks.CSS
      iex> Meeseeks.all("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p")) |> List.first()
      #Meeseeks.Result<{ <p>1</p> }>
  """
  @spec all(queryable, selectors) :: [Result.t()] | {:error, Error.t()}
  def all(queryable, selectors) do
    all(queryable, selectors, %{})
  end

  @spec all(queryable, selectors, Context.t()) :: [Result.t()] | {:error, Error.t()}
  def all(queryable, selectors, context)

  def all({:error, _} = error, _selectors, _context), do: error

  def all(%Document{} = queryable, selectors, context) do
    Select.all(queryable, selectors, context)
  end

  def all(%Result{} = queryable, selectors, context) do
    Select.all(queryable, selectors, context)
  end

  def all(source, selectors, context) do
    case parse(source) do
      {:error, reason} -> {:error, reason}
      document -> Select.all(document, selectors, context)
    end
  end

  @doc """
  Returns `{:ok, Result}` for the first node in the queryable (depth-first)
  matching a selector, or
  `{:error, %Meeseeks.Error{type: :select, reason: :no_match}}` if none do.

  Optionally accepts a `Meeseeks.Context` map.

  Parses the source if it is not a `Meeseeks.Document` or `Meeseeks.Result`,
  and may return `{:error, %Meeseeks.Error{type: parser}` if there is a parse
  error.

  If multiple selections are being ran on the same unparsed source, parse
  first to avoid unnecessary computation.

  ## Examples

      iex> import Meeseeks.CSS
      iex> Meeseeks.fetch_one("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p")) |> elem(1)
      #Meeseeks.Result<{ <p>1</p> }>
  """
  @spec fetch_one(queryable, selectors) :: {:ok, Result.t()} | {:error, Error.t()}
  def fetch_one(queryable, selectors) do
    fetch_one(queryable, selectors, %{})
  end

  @spec fetch_one(queryable, selectors, Context.t()) :: {:ok, Result.t()} | {:error, Error.t()}
  def fetch_one(queryable, selectors, context)

  def fetch_one({:error, _} = error, _selectors, _context), do: error

  def fetch_one(%Document{} = queryable, selectors, context) do
    Select.fetch_one(queryable, selectors, context)
  end

  def fetch_one(%Result{} = queryable, selectors, context) do
    Select.fetch_one(queryable, selectors, context)
  end

  def fetch_one(source, selectors, context) do
    case parse(source) do
      {:error, reason} -> {:error, reason}
      document -> Select.fetch_one(document, selectors, context)
    end
  end

  @doc """
  Returns a `Result` for the first node in the queryable (depth-first)
  matching a selector, or `nil` if none do.

  Optionally accepts a `Meeseeks.Context` map.

  Parses the source if it is not a `Meeseeks.Document` or `Meeseeks.Result`,
  and may return `{:error, %Meeseeks.Error{type: parser}` if there is a parse
  error.

  If multiple selections are being ran on the same unparsed source, parse
  first to avoid unnecessary computation.

  ## Examples

      iex> import Meeseeks.CSS
      iex> Meeseeks.one("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p"))
      #Meeseeks.Result<{ <p>1</p> }>
  """
  @spec one(queryable, selectors) :: Result.t() | nil | {:error, Error.t()}
  def one(queryable, selectors) do
    one(queryable, selectors, %{})
  end

  @spec one(queryable, selectors, Context.t()) :: Result.t() | nil | {:error, Error.t()}
  def one(queryable, selectors, context)

  def one({:error, _} = error, _selectors, _context), do: error

  def one(%Document{} = queryable, selectors, context) do
    Select.one(queryable, selectors, context)
  end

  def one(%Result{} = queryable, selectors, context) do
    Select.one(queryable, selectors, context)
  end

  def one(source, selectors, context) do
    case parse(source) do
      {:error, reason} -> {:error, reason}
      document -> Select.one(document, selectors, context)
    end
  end

  @doc """
  Returns the accumulated result of walking the queryable, accumulating nodes
  that match a selector. Prefer `all` or `one`- `select` should only be used
  when a custom accumulator is required.

  Requires that a `Meeseeks.Accumulator` has been added to the context via
  `Meeseeks.Context.add_accumulator/2`, and will raise an error if it hasn't.

  Parses the source if it is not a `Meeseeks.Document` or `Meeseeks.Result`,
  and may return `{:error, %Meeseeks.Error{type: parser}` if there is a parse
  error.

  If multiple selections are being ran on the same unparsed source, parse
  first to avoid unnecessary computation.

  ## Examples

      iex> import Meeseeks.CSS
      iex> accumulator = %Meeseeks.Accumulator.One{}
      iex> context = Meeseeks.Context.add_accumulator(%{}, accumulator)
      iex> Meeseeks.select("<div id=main><p>1</p><p>2</p><p>3</p></div>", css("#main p"), context)
      #Meeseeks.Result<{ <p>1</p> }>
  """
  @spec select(queryable, selectors, Context.t()) :: any | {:error, Error.t()}
  def select(queryable, selectors, context)

  def select({:error, _} = error, _selectors, _context), do: error

  def select(%Document{} = queryable, selectors, context) do
    Select.select(queryable, selectors, context)
  end

  def select(%Result{} = queryable, selectors, context) do
    Select.select(queryable, selectors, context)
  end

  def select(source, selectors, context) do
    case parse(source) do
      {:error, reason} -> {:error, reason}
      document -> Select.select(document, selectors, context)
    end
  end

  # Extract

  @doc """
  Returns the value of an attribute in a result, or nil if there isn't one.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.attr(result, "id")
      "example"
  """
  @spec attr(extractable, String.t()) :: String.t() | nil
  def attr(extractable, attribute)
  def attr(nil, _), do: nil
  def attr(%Result{} = result, attribute), do: Result.attr(result, attribute)
  def attr(x, _attribute), do: raise_cannot_extract(x, "attr/2")

  @doc """
  Returns a result's attributes list, which may be empty, or nil if the
  result represents a node without attributes.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.attrs(result)
      [{"id", "example"}]
  """
  @spec attrs(extractable) :: [{String.t(), String.t()}] | nil
  def attrs(extractable)
  def attrs(nil), do: nil
  def attrs(%Result{} = result), do: Result.attrs(result)
  def attrs(x), do: raise_cannot_extract(x, "attrs/1")

  @doc """
  Returns the combined data of a result or the result's children, which may
  be an empty string.

  Once the data has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  Data is the content of `<script>` or `<style>` tags, or the content of
  comments starting with "[CDATA[" and ending with "]]". The latter behavior
  is to support the extraction of CDATA from HTML, since HTML5 parsers parse
  CDATA as comments.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result1 = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.data(result1)
      ""
      iex> result2 = Meeseeks.one("<script id=example>Hi</script>", css("#example"))
      #Meeseeks.Result<{ <script id="example">Hi</script> }>
      iex> Meeseeks.data(result2)
      "Hi"
  """
  @spec data(extractable) :: String.t() | nil
  def data(extractable)
  def data(nil), do: nil
  def data(%Result{} = result), do: Result.data(result)
  def data(x), do: raise_cannot_extract(x, "data/1")

  @doc """
  Returns a map of a result's data attributes, or nil if the result
  represents a node without attributes.

  Behaves like HTMLElement.dataset; only valid data attributes are included,
  and attribute names have "data-" removed and are converted to camelCase.

  See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div id=example data-x-val=1 data-y-val=2></div>", css("#example"))
      #Meeseeks.Result<{ <div id="example" data-x-val="1" data-y-val="2"></div> }>
      iex> Meeseeks.dataset(result)
      %{"xVal" => "1", "yVal" => "2"}
  """
  @spec dataset(extractable) :: %{optional(String.t()) => String.t()} | nil
  def dataset(extractable)
  def dataset(nil), do: nil
  def dataset(%Result{} = result), do: Result.dataset(result)
  def dataset(x), do: raise_cannot_extract(x, "dataset/1")

  @doc """
  Returns a string representing the combined HTML of a document or result
  and its descendants.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> document = Meeseeks.parse("<div id=example>Hi</div>")
      iex> Meeseeks.html(document)
      "<html><head></head><body><div id=\\"example\\">Hi</div></body></html>"
      iex> result = Meeseeks.one(document, css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.html(result)
      "<div id=\\"example\\">Hi</div>"
  """
  @spec html(extractable) :: String.t() | nil
  def html(extractable)
  def html(nil), do: nil
  def html(%Document{} = document), do: Document.html(document)
  def html(%Result{} = result), do: Result.html(result)
  def html(x), do: raise_cannot_extract(x, "html/1")

  @doc """
  Returns the combined text of a result or the result's children, which may
  be an empty string.

  Once the text has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div>Hello, <b>World!</b></div>", css("div"))
      #Meeseeks.Result<{ <div>Hello, <b>World!</b></div> }>
      iex> Meeseeks.own_text(result)
      "Hello,"
  """
  @spec own_text(extractable) :: String.t() | nil
  def own_text(extractable)
  def own_text(nil), do: nil
  def own_text(%Result{} = result), do: Result.own_text(result)
  def own_text(x), do: raise_cannot_extract(x, "own_text/1")

  @doc """
  Returns a result's tag, or `nil` if the result represents a node without a
  tag.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div id=example>Hi</div>", css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.tag(result)
      "div"
  """
  @spec tag(extractable) :: String.t() | nil
  def tag(extractable)
  def tag(nil), do: nil
  def tag(%Result{} = result), do: Result.tag(result)
  def tag(x), do: raise_cannot_extract(x, "tag/1")

  @doc """
  Returns the combined text of a result or the result's descendants, which
  may be an empty string.

  Once the text has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> result = Meeseeks.one("<div>Hello, <b>World!</b></div>", css("div"))
      #Meeseeks.Result<{ <div>Hello, <b>World!</b></div> }>
      iex> Meeseeks.text(result)
      "Hello, World!"
  """
  @spec text(extractable) :: String.t() | nil
  def text(extractable)
  def text(nil), do: nil
  def text(%Result{} = result), do: Result.text(result)
  def text(x), do: raise_cannot_extract(x, "text/1")

  @doc """
  Returns the `Meeseeks.TupleTree` of a document or result and its
  descendants.

  Nil input returns `nil`.

  ## Examples

      iex> import Meeseeks.CSS
      iex> document = Meeseeks.parse("<div id=example>Hi</div>")
      iex> Meeseeks.tree(document)
      [{"html", [],
        [{"head", [], []},
         {"body", [], [{"div", [{"id", "example"}], ["Hi"]}]}]}]
      iex> result = Meeseeks.one(document, css("#example"))
      #Meeseeks.Result<{ <div id="example">Hi</div> }>
      iex> Meeseeks.tree(result)
      {"div", [{"id", "example"}], ["Hi"]}
  """
  @spec tree(extractable) :: TupleTree.t() | nil
  def tree(extractable)
  def tree(nil), do: nil
  def tree(%Document{} = document), do: Document.tree(document)
  def tree(%Result{} = result), do: Result.tree(result)
  def tree(x), do: raise_cannot_extract(x, "tree/1")

  defp raise_cannot_extract(target, extractor) do
    raise "Cannot run Meeseeks.#{extractor} on #{inspect(target)}"
  end
end
