defmodule Meeseeks.Extractor.Tag do
  @moduledoc false

  alias Meeseeks.Document.{Element, Node}

  @other_nodes Node.types() -- [Element]

  # from_node

  @spec from_node(Node.t()) :: String.t() | nil
  def from_node(node)

  def from_node(%Element{tag: tag}), do: tag

  def from_node(%{__struct__: struct}) when struct in @other_nodes, do: nil
end
