defmodule Meeseeks.Selector.Element.Namespace do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element

  defstruct value: nil

  @impl true
  def match(%Element.Namespace{value: "*"}, %Document.Element{}, _document, _context) do
    true
  end

  def match(selector, %Document.Element{} = element, _document, _context) do
    element.namespace == selector.value
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
