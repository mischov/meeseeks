defmodule Meeseeks.Selector.Element.Attribute.ValueDash do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.Attribute.Helpers

  defstruct attribute: nil, value: nil

  def match(selector, %Document.Element{} = element, _document, _context) do
    value = Helpers.get(element.attributes, selector.attribute)
    value == selector.value || String.starts_with?(value, selector.value <> "-")
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
