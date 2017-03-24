defmodule Meeseeks.Selector.Element.Attribute.AttributePrefix do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document

  defstruct attribute: nil

  def match?(selector, %Document.Element{} = element, _document) do
    Enum.any?(element.attributes, fn({attribute, _}) ->
      String.starts_with?(attribute, selector.attribute)
    end)
  end

  def match?(_selector, _node, _document) do
    false
  end
end
