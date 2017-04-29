defmodule Meeseeks.Selector.Combinator.PreviousSiblings do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %{parent: nil}, _document) do
    nil
  end

  def next(_combinator, node, document) do
    case Document.previous_siblings(document, node.id) do
      [] -> nil
      previous_siblings -> Document.get_nodes(document, previous_siblings)
    end
  end
end
