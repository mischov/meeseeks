defmodule Meeseeks.Result do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Result
  alias Meeseeks.TupleTree

  @enforce_keys [:document, :id]
  defstruct(
    document: nil,
    id: nil
  )

  @type t :: %Result{document: Document.t,
                     id: Document.node_id}

  @spec tag(Result.t) :: String.t | nil

  def tag(%Result{id: id, document: document}) do
    case Document.get_node(document, id) do
      %Document.Element{tag: tag} -> tag
      _ -> nil
    end
  end

  @spec attrs(Result.t) :: [{String.t, String.t}] | nil

  def attrs(%Result{id: id, document: document}) do
    case Document.get_node(document, id) do
      %Document.Element{attributes: attributes} -> attributes
      _ -> nil
    end
  end

  @spec attr(Result.t, String.t) :: String.t | nil

  def attr(%Result{id: id, document: document}, attribute) do
    case Document.get_node(document, id) do
      %Document.Element{attributes: attributes} ->
        {_attr, value} = List.keyfind(attributes, attribute, 0, {nil, nil})
        value
      _ ->
        nil
    end
  end

  @spec tree(Result.t) :: TupleTree.node_t

  def tree(%Result{id: id, document: document}) do
    build_tree(document, id)
  end

  defp build_tree(document, id) do
    case Document.get_node(document, id) do
      %Document.Comment{content: content} -> {:comment, content}
      %Document.Data{content: content} -> content
      %Document.Text{content: content} -> content
      %Document.Element{} = element ->
        {element.tag,
         element.attributes,
         element.children
         |> Enum.reverse()
         |> Enum.map(&(build_tree document, &1))}
    end
  end

  @spec text(Result.t) :: String.t

  def text(%Result{id: id, document: document}) do
    document
    |> get_text(id, "")
    |> String.trim()
  end

  defp get_text(document, id, acc) do
    case Document.get_node(document, id) do
      %Document.Comment{} -> acc
      %Document.Data{} -> acc
      %Document.Text{content: content} -> << acc <> normalize_ws content >>
      %Document.Element{children: children} ->
        children
        |> Enum.reverse()
        |> Enum.reduce(acc, &(get_text document, &1, &2))
    end
  end

  @spec data(Result.t) :: String.t

  def data(%Result{id: id, document: document}) do
    document
    |> get_data(id, "")
    |> String.trim()
  end

  defp get_data(document, id, acc) do
    case Document.get_node(document, id) do
      %Document.Comment{} -> acc
      %Document.Text{} -> acc
      %Document.Data{content: content} -> << acc <> normalize_ws content >>
      %Document.Element{children: children} ->
        children
        |> Enum.reverse()
        |> Enum.reduce(acc, &(get_data document, &1, &2))
    end
  end

  defp normalize_ws(string) do
    string
    |> String.replace(~r/[\s]+/, " ")
  end
end

defimpl Inspect, for: Meeseeks.Result do
  @moduledoc false

  def inspect(result, _opts) do
    "%Meeseeks.Result{id: #{result.id}, ...}"
  end
end
