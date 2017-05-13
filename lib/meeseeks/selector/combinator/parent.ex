defmodule Meeseeks.Selector.Combinator.Parent do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, node, document) do
    case Document.parent(document, node.id) do
      nil -> nil
      parent -> Document.get_node(document, parent)
    end
  end
end
