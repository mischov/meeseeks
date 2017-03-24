defmodule Meeseeks.Selector.Element.Attribute.ValueSuffix do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.Attribute.Helpers

  defstruct attribute: nil, value: nil

  def match?(selector, %Document.Element{} = element, _document) do
    value = Helpers.get(element.attributes, selector.attribute)
    String.ends_with?(value, selector.value)
  end

  def match?(_selector, _node, _document) do
    false
  end
end
