defmodule Meeseeks.Selector.Combinator.Ancestors do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, node, document) do
    case Document.ancestors(document, node.id) do
      [] -> nil
      ancestors -> Document.get_nodes(document, ancestors)
    end
  end
end
