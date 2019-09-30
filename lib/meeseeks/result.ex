defmodule Meeseeks.Result do
  @moduledoc """
  Results are the product of running selections on a document, and package
  together a node id and the `Meeseeks.Document` for which that id is
  valid.

  Results are generally used in one of two ways: either data, such as an
  element's tag, is extracted from a result, or further selections are ran
  using the result as a source.

  When a result is used as a source for further selection, the original
  document the result came from is used for context, meaning that questions
  about the results ancestors may be asked, but also that queries involving
  ancestors need to account for the whole document, not just the contents of
  the result.

  ## Examples

      iex> import Meeseeks.CSS
      iex> document = Meeseeks.parse("<div><ul><li>1</li><li>2</li></ul></div>")
      #Meeseeks.Document<{...}>
      iex> ul = Meeseeks.one(document, css("ul"))
      #Meeseeks.Result<{ <ul><li>1</li><li>2</li></ul> }>
      iex> Meeseeks.tag(ul)
      "ul"
      iex> Meeseeks.all(ul, css("li")) |> List.last()
      #Meeseeks.Result<{ <li>2</li> }>
  """

  alias Meeseeks.{Document, Result, TupleTree}

  @enforce_keys [:document, :id]
  defstruct document: nil, id: nil

  @type t :: %Result{document: Document.t(), id: Document.node_id()}

  @doc """
  Returns the value for attribute in result, or nil if there isn't one.
  """
  @spec attr(Result.t(), String.t()) :: String.t() | nil
  def attr(result, attribute)

  def attr(%Result{id: id, document: document}, attribute) do
    node = Document.get_node(document, id)
    Document.Node.attr(node, attribute)
  end

  @doc """
  Returns the result's attributes list, which may be empty, or nil if
  result represents a node without attributes.
  """
  @spec attrs(Result.t()) :: [{String.t(), String.t()}] | nil
  def attrs(result)

  def attrs(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.attrs(node)
  end

  @doc """
  Returns the combined data of result or result's children, which may be an
  empty string.

  Once the data has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  Data is the content of `<script>` or `<style>` tags, or the content of
  comments starting with "[CDATA[" and ending with "]]". The latter behavior
  is to support the extraction of CDATA from HTML, since HTML5 parsers parse
  CDATA as comments.

  ## Options

    * `:collapse_whitespace` - Boolean determining whether or not to replace
      blocks of whitespace with a single space character. Defaults to `true`.
    * `:trim` - Boolean determining whether or not to trim the resulting
      text. Defaults to `true`.
  """
  @spec data(Result.t(), Keyword.t()) :: String.t()
  def data(result, opts \\ [])

  def data(%Result{id: id, document: document}, opts) do
    node = Document.get_node(document, id)
    Document.Node.data(node, document, opts)
  end

  @doc """
  Returns a map of result's data attributes, or nil if result represents a
  node without attributes.

  Behaves like HTMLElement.dataset; only valid data attributes are included,
  and attribute names have "data-" removed and are converted to camelCase.

  See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset
  """
  @spec dataset(Result.t()) :: %{optional(String.t()) => String.t()} | nil
  def dataset(result) do
    case attrs(result) do
      nil -> nil
      [] -> %{}
      attributes -> attributes_to_dataset(attributes)
    end
  end

  defp attributes_to_dataset(attributes) do
    Enum.reduce(attributes, %{}, fn {attribute, value}, dataset ->
      case Regex.run(~r/^data-([a-z0-9\-\.\:\_]+)$/, attribute) do
        [_, raw_name] -> Map.put(dataset, dataset_name(raw_name), value)
        _ -> dataset
      end
    end)
  end

  defp dataset_name(raw_name) do
    Regex.replace(~r/\-([a-z])/, raw_name, fn _, c ->
      String.upcase(c)
    end)
  end

  @doc """
  Returns the combined HTML of result and its descendants.
  """
  @spec html(Result.t()) :: String.t()
  def html(result)

  def html(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.html(node, document)
  end

  @doc """
  Returns the combined text of result or result's children, which may be an
  empty string.

  Once the text has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  ## Options

    * `:collapse_whitespace` - Boolean determining whether or not to replace
      blocks of whitespace with a single space character. Defaults to `true`.
    * `:trim` - Boolean determining whether or not to trim the resulting
      text. Defaults to `true`.
  """
  @spec own_text(Result.t(), Keyword.t()) :: String.t()
  def own_text(result, opts \\ [])

  def own_text(%Result{id: id, document: document}, opts) do
    node = Document.get_node(document, id)
    Document.Node.own_text(node, document, opts)
  end

  @doc """
  Returns result's tag, or nil if result represents a node without a tag.
  """
  @spec tag(Result.t()) :: String.t() | nil
  def tag(result)

  def tag(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.tag(node)
  end

  @doc """
  Returns the combined text of result or result's descendants, which may be
  an empty string.

  Once the text has been combined the whitespace is compacted by replacing
  all instances of more than one whitespace character with a single space
  and then trimmed.

  ## Options

    * `:collapse_whitespace` - Boolean determining whether or not to replace
      blocks of whitespace with a single space character. Defaults to `true`.
    * `:trim` - Boolean determining whether or not to trim the resulting
      text. Defaults to `true`.
  """
  @spec text(Result.t(), Keyword.t()) :: String.t()
  def text(result, opts \\ [])

  def text(%Result{id: id, document: document}, opts) do
    node = Document.get_node(document, id)
    Document.Node.text(node, document, opts)
  end

  @doc """
  Returns a `Meeseeks.TupleTree` of result and its descendants.
  """
  @spec tree(Result.t()) :: TupleTree.node_t()
  def tree(result)

  def tree(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.tree(node, document)
  end
end

defimpl Inspect, for: Meeseeks.Result do
  @moduledoc false

  alias Meeseeks.Result

  def inspect(result, _opts) do
    result_html =
      Result.html(result)
      |> String.replace(~r/[\s]+/, " ")

    "#Meeseeks.Result<{ #{result_html} }>"
  end
end
