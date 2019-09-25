defmodule Meeseeks.Extractor.Data do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.{Data, Element, Node}
  alias Meeseeks.Extractor.Helpers

  @other_nodes Node.types() -- [Data, Element]

  # from_node

  @spec from_node(Node.t(), Document.t()) :: iodata()
  def from_node(node, document)

  def from_node(%Data{content: content}, _), do: content

  def from_node(%Element{id: id}, document) do
    Helpers.child_nodes(document, id)
    |> Enum.filter(&Helpers.data_node?/1)
    |> Enum.map(&from_node(&1, document))
    |> Enum.intersperse(" ")
  end

  def from_node(%{__struct__: struct}, _) when struct in @other_nodes, do: []
end
