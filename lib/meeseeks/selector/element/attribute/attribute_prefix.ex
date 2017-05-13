defmodule Meeseeks.Selector.Element.Attribute.AttributePrefix do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document

  defstruct attribute: nil

  def match(selector, %Document.Element{} = element, _document, _context) do
    Enum.any?(element.attributes, fn({attribute, _}) ->
      String.starts_with?(attribute, selector.attribute)
    end)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
