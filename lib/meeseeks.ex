defmodule Meeseeks do

  alias Meeseeks.{Document, Parser, Result, Select, Selector, TupleTree}

  @moduledoc """
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
  """

  @type source :: String.t | TupleTree.t
  @type queryable :: source | Document.t | Result.t
  @type selectors :: String.t | Selector.t | [Selector.t]

  # Parse

  @doc """
  Parses a source (HTML string or tuple-tree) into a `Document`.

  ## Examples

      iex> Meeseeks.parse("<div id=main><p>Hello, Meeseeks!</p></div>")
      %Meeseeks.Document{...}
      iex> Meeseeks.parse({"div", [{"id", "main"}], [{"p", [], ["Hello, Meeseeks!"]}]})
      %Meeseeks.Document{...}
  """

  @spec parse(source) :: Document.t

  def parse(source) do
    Parser.parse(source)
  end

  # Select

  @doc """
  Returns a `Result` for each node in the queryable matching a selector.

  ## Examples

      iex> Meeseeks.all("<div id=main><p>1</p><p>2</p><p>3</p></div>", "#main p")
      [%Meeseeks.Result{...}, %Meeseeks.Result{...}, %Meeseeks.Result{...}]
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

      iex> Meeseeks.one("<div id=main><p>1</p><p>2</p><p>3</p></div>", "#main p")
      %Meeseeks.Result{...}
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
  Returns `Result`'s tag or nil.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.tag(result)
      "div"
  """

  @spec tag(Result.t) :: String.t | nil

  def tag(result) do
    Result.tag(result)
  end

  @doc """
  Returns `Result`'s attribute vector or nil.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.attrs(result)
      [{"id", "example"}]
  """

  @spec attrs(Result.t) :: [{String.t, String.t}] | nil

  def attrs(result) do
    Result.attrs(result)
  end

  @doc """
  Returns `Result`'s value for the attribute or nil.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.attr(result, "id")
      "example"
  """

  @spec attr(Result.t, String.t) :: String.t | nil

  def attr(result, attribute) do
    Result.attr(result, attribute)
  end

  @doc """
  Returns a tuple-tree representing `Result` and its children.

  If `Result` is a `Text` or `Data` node, returns their string value.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.tree(result)
      {"div", [{"id", "example"}], ["Hi"]}
  """

  @spec tree(Result.t) :: TupleTree.node_t

  def tree(result) do
    Result.tree(result)
  end

  @doc """
  Returns the combined text of `Result` and its children, which may be an empty string.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.text(result)
      "Hi"
  """

  @spec text(Result.t) :: String.t

  def text(result) do
    Result.text(result)
  end

  @doc """
  Returns the combined data (contents of script and style tags) of `Result` and its children, which may be an empty string.

  ## Examples

      iex> result = Meeseeks.one("<div id=example>Hi</div>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.data(result)
      ""
      iex> result = Meeseeks.one("<script id=example>Hi</script>", "#example")
      %Meeseeks.Result{...}
      iex> Meeseeks.data(result)
      "Hi"
  """

  @spec data(Result.t) :: String.t

  def data(result) do
    Result.data(result)
  end
end
