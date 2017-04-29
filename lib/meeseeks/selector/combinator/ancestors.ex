defmodule Meeseeks.Selector.Combinator.Ancestors do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, node, document) do
    case Document.ancestors(document, node.id) do
      [] -> nil
      ancestors -> Document.get_nodes(document, ancestors)
    end
  end
end
