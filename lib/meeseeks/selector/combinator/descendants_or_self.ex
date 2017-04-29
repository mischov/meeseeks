defmodule Meeseeks.Selector.Combinator.DescendantsOrSelf do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{children: []} = element, _document) do
    element
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.descendants(document, element.id) do
      [] -> [element]
      descendants -> [element | Document.get_nodes(document, descendants)]
    end
  end

  def next(_combinator, node, _document) do
    node
  end
end
