defmodule Meeseeks.Selector.Element.Attribute.AttributePrefix do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Document

  defstruct attribute: nil

  @impl true
  def match(selector, %Document.Element{} = element, _document, _context) do
    Enum.any?(element.attributes, fn {attribute, _} ->
      String.starts_with?(attribute, selector.attribute)
    end)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
