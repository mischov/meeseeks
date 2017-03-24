defmodule Meeseeks.Selector.Combinator.NextSiblingElement do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{parent: nil}, _document) do
    nil
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.next_siblings(document, element.id) do
      [] -> nil
      next_siblings ->
        case next_sibling_element(next_siblings, document) do
          nil -> nil
          next_sibling_element ->
            Document.get_node(document, next_sibling_element)
        end
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end

  defp next_sibling_element(next_siblings, document) do
    Enum.find(next_siblings, nil, &(Document.element? document, &1))
  end
end
