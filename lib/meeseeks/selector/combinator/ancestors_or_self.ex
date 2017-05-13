defmodule Meeseeks.Selector.Combinator.AncestorsOrSelf do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, node, document) do
    case Document.ancestors(document, node.id) do
      [] -> node
      ancestors -> [node | Document.get_nodes(document, ancestors)]
    end
  end
end
