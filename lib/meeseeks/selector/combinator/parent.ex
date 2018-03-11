defmodule Meeseeks.Selector.Combinator.Parent do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, node, document) do
    case Document.parent(document, node.id) do
      nil -> nil
      parent -> Document.get_node(document, parent)
    end
  end
end
