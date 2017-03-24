defmodule Meeseeks.Selector.Combinator.DescendantElements do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{children: []}, _document) do
    nil
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.descendants(document, element.id) do
      [] -> nil
      descendants ->
        case Enum.filter(descendants, &(Document.element? document, &1)) do
          [] -> nil
          descendant_elements ->
            Document.get_nodes(document, descendant_elements)
        end
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
