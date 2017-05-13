defmodule Meeseeks.Selector.Combinator.NextSiblings do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %{parent: nil}, _document) do
    nil
  end

  def next(_combinator, node, document) do
    case Document.next_siblings(document, node.id) do
      [] -> nil
      next_siblings -> Document.get_nodes(document, next_siblings)
    end
  end
end
