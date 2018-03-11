defmodule Meeseeks.Selector.Combinator.PreviousSiblings do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
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
