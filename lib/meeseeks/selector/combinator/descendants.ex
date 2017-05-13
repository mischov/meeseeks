defmodule Meeseeks.Selector.Combinator.Descendants do
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
      descendants -> Document.get_nodes(document, descendants)
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
