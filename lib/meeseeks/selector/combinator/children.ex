defmodule Meeseeks.Selector.Combinator.Children do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{children: []}, _document) do
    nil
  end

  def next(_combinator, %Document.Element{} = element, document) do
    case Document.children(document, element.id) do
      [] -> nil
      children -> Document.get_nodes(document, children)
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
