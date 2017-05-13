defmodule Meeseeks.Selector.Element.Namespace do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element

  defstruct value: nil

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
