defmodule Meeseeks.Selector.Element.Attribute.Helpers do
  @moduledoc false

  def get(attributes, attribute) do
    {_attribute, value} = List.keyfind(attributes, attribute, 0, {nil, ""})
    value
  end
end
