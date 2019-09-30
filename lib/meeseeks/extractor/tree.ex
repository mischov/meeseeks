defmodule Meeseeks.Extractor.Tree do
  @moduledoc false

  alias Meeseeks.{Document, TupleTree}

  alias Meeseeks.Document.{
    Comment,
    Data,
    Doctype,
    Element,
    Node,
    ProcessingInstruction,
    Text
  }

  alias Meeseeks.Extractor.Helpers

  # from_node

  @spec from_node(Node.t(), Document.t()) :: TupleTree.node_t()
  def from_node(node, document)

  def from_node(%Comment{content: content}, _), do: {:comment, content}

  def from_node(%Data{content: content}, _), do: content

  def from_node(%Doctype{name: name, public: public, system: system}, _) do
    {:doctype, name, public, system}
  end

  def from_node(%Element{} = node, document) do
    child_nodes = Helpers.child_nodes(document, node.id)
    {node.tag, node.attributes, Enum.map(child_nodes, &from_node(&1, document))}
  end

  def from_node(%ProcessingInstruction{target: target, data: data}, _) do
    {:pi, target, data}
  end

  def from_node(%Text{content: content}, _), do: content
end
