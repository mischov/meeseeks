defmodule Meeseeks.Selector.Combinator.AncestorsOrSelf do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, node, document) do
    case Document.ancestors(document, node.id) do
      [] -> node
      ancestors -> [node | Document.get_nodes(document, ancestors)]
    end
  end
end
