defmodule Meeseeks.Selector.Combinator.NextSiblingElements do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, %Document.Element{parent: nil}, _document) do
    nil
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.next_siblings(document, element.id) do
      [] ->
        nil

      next_siblings ->
        case Enum.filter(next_siblings, &Document.element?(document, &1)) do
          [] ->
            nil

          next_sibling_elements ->
            Document.get_nodes(document, next_sibling_elements)
        end
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
