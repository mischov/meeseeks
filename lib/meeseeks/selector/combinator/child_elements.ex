defmodule Meeseeks.Selector.Combinator.ChildElements do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, %Document.Element{children: []}, _document) do
    nil
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.children(document, element.id) do
      [] ->
        nil

      children ->
        case Enum.filter(children, &Document.element?(document, &1)) do
          [] ->
            nil

          child_elements ->
            Document.get_nodes(document, child_elements)
        end
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
