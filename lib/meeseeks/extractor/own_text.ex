defmodule Meeseeks.Extractor.OwnText do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.{Element, Node, Text}
  alias Meeseeks.Extractor.Helpers

  @other_nodes Node.types() -- [Element, Text]

  # from_node

  @spec from_node(Node.t(), Document.t()) :: iodata()
  def from_node(node, document)

  def from_node(%Element{id: id}, document) do
    Helpers.child_nodes(document, id)
    |> Enum.filter(&Helpers.text_node?/1)
    |> join_nodes(document)
  end

  def from_node(%Text{content: content}, _), do: content

  def from_node(%{__struct__: struct}, _) when struct in @other_nodes, do: []

  # join_nodes

  defp join_nodes([], _document), do: []

  defp join_nodes([node], document), do: from_node(node, document)

  defp join_nodes(nodes, document), do: join_nodes(nodes, [], document)

  defp join_nodes([], acc, _document), do: :lists.reverse(acc)

  defp join_nodes([node | nodes], acc, document) do
    acc = join_node(node, acc, document)
    join_nodes(nodes, acc, document)
  end

  # Head
  defp join_node(node, [], document) do
    case from_node(node, document) do
      [] -> []
      "" -> []
      iodata -> [iodata]
    end
  end

  # Tail
  defp join_node(node, acc, document) do
    case from_node(node, document) do
      [] ->
        acc

      "" ->
        acc

      iodata ->
        [previous | _] = acc

        if Helpers.ends_in_whitespace?(previous) do
          [iodata | acc]
        else
          [iodata, " " | acc]
        end
    end
  end
end
