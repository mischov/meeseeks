defmodule Meeseeks.Selector.Element.Attribute.ValueIncludes do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.Attribute.Helpers

  defstruct attribute: nil, value: nil

  def match?(selector, %Document.Element{} = element, _document) do
    values = Helpers.get(element.attributes, selector.attribute) |> String.split(~r/[ ]+/)
    Enum.any?(values, &(&1 == selector.value))
  end

  def match?(_selector, _node, _document) do
    false
  end
end
