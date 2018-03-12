defmodule Meeseeks.Selector.Element.Attribute.Attribute do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Document

  defstruct attribute: nil

  @impl true
  def match(selector, %Document.Element{} = element, _document, _context) do
    Enum.any?(element.attributes, fn {attribute, _} ->
      attribute == selector.attribute
    end)
  end

  def match(_selector, _node, _document, _context) do
    false
  end
end
