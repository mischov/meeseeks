defmodule Meeseeks.Selector.Combinator.Children do
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
      [] -> nil
      children -> Document.get_nodes(document, children)
    end
  end

  def next(_combinator, _element, _document) do
    nil
  end
end
