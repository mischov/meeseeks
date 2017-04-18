defmodule Meeseeks.Result do
  @moduledoc """
  Results are the product of running selections on a document, and package
  together a node id and the `Meeseeks.Document` for which that id is
  valid.

  Results may be used in two ways:

    - Data, such as an element's tag, can be extracted from a result
    - Further selections may be ran using the result as a source

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

  alias Meeseeks.Document
  alias Meeseeks.Result
  alias Meeseeks.TupleTree

  @enforce_keys [:document, :id]
  defstruct document: nil, id: nil

  @type t :: %Result{document: Document.t,
                     id: Document.node_id}

  @doc """
  Returns the value for attribute in result, or nil if there isn't one.
  """
  @spec attr(Result.t, String.t) :: String.t | nil
  def attr(result, attribute)

  def attr(%Result{id: id, document: document}, attribute) do
    node = Document.get_node(document, id)
    Document.Node.attr(node, attribute)
  end

  @doc """
  Returns the result's attributes list, which may be empty, or nil if
  result represents a node without attributes.
  """
  @spec attrs(Result.t) :: [{String.t, String.t}] | nil
  def attrs(result)

  def attrs(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.attrs(node)
  end

  @doc """
  Returns the combined data of result or result's children, which may be an
  empty string.
  """
  @spec data(Result.t) :: String.t
  def data(result)

  def data(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.data(node, document)
    |> String.trim()
  end

  @doc """
  Returns a map of result's data attributes, or nil if result represents a
  node without attributes.

  Behaves like HTMLElement.dataset; only valid data attributes are included,
  and attribute names have "data-" removed and are converted to camelCase.

  See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset
  """
  @spec dataset(Result.t) :: %{optional(String.t) => String.t} | nil
  def dataset(result) do
    case attrs(result) do
      nil -> nil
      [] -> %{}
      attributes -> attributes_to_dataset(attributes)
    end
  end

  defp attributes_to_dataset(attributes) do
    Enum.reduce(attributes, %{}, fn({attribute, value}, dataset) ->
      case Regex.run(~r/^data-([a-z0-9\-\.\:\_]+)$/, attribute) do
        [_, raw_name] -> Map.put(dataset, dataset_name(raw_name), value)
        _ -> dataset
      end
    end)
  end

  defp dataset_name(raw_name) do
    Regex.replace(~r/\-([a-z])/, raw_name, fn(_, c) ->
      String.upcase(c)
    end)
  end

  @doc """
  Returns the combined HTML of result and its descendants.
  """
  @spec html(Result.t) :: String.t
  def html(result)

  def html(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.html(node, document)
    |> String.trim()
  end

  @doc """
  Returns the combined text of result or result's children, which may be an
  empty string.
  """
  @spec own_text(Result.t) :: String.t
  def own_text(result)

  def own_text(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.own_text(node, document)
    |> String.trim()
  end

  @doc """
  Returns result's tag, or nil if result represents a node without a tag.
  """
  @spec tag(Result.t) :: String.t | nil
  def tag(result)

  def tag(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.tag(node)
  end

  @doc """
  Returns the combined text of result or result's descendants, which may be
  an empty string.
  """
  @spec text(Result.t) :: String.t
  def text(result)

  def text(%Result{id: id, document: document}) do
    node = Document.get_node(document, id)
    Document.Node.text(node, document)
    |> String.trim()
  end

  @doc """
  Returns a `Meeseeks.TupleTree` of result and its descendants.
  """
  @spec tree(Result.t) :: TupleTree.node_t
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
    result_html = Result.html(result)
    |> String.replace(~r/[\s]+/, " ")
    "#Meeseeks.Result<{ #{result_html} }>"
  end
end
