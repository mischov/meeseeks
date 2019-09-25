defmodule Meeseeks.Extractor.Attribute do
  @moduledoc false

  alias Meeseeks.Document.{Element, Node}

  @other_nodes Node.types() -- [Element]

  # from_node

  @spec from_node(Node.t(), String.t()) :: String.t() | nil
  def from_node(node, attribute)

  def from_node(%Element{attributes: attributes}, attribute) do
    {_attribute, value} = List.keyfind(attributes, attribute, 0, {nil, nil})
    value
  end

  def from_node(%{__struct__: struct}, _) when struct in @other_nodes, do: nil
end
