defmodule Meeseeks.Selector.Attribute do
  @moduledoc false

  alias Meeseeks.Selector.Attribute

  defstruct(
    match: nil,
    attribute: nil,
    value: nil
  )

  @type match :: :attribute
               | :attribute_prefix
               | :class
               | :value
               | :value_prefix
               | :value_suffix
               | :value_contains
  @type t :: %Attribute{match: match | nil,
                        attribute: String.t | nil,
                        value: String.t | nil}

  @spec match?([{String.t, String.t}], t) :: boolean

  def match?(attributes, %Attribute{match: :attribute} = a) do
    attribute?(attributes, a.attribute)
  end

  def match?(attributes, %Attribute{match: :attribute_prefix} = a) do
    attribute_with_prefix?(attributes, a.attribute)
  end

  def match?(attributes, %Attribute{match: :class} = a) do
    class_string = attribute_value(attributes, "class")
    classes = String.split(class_string, " ")
    Enum.any?(classes, &(&1 == a.value))
  end

  def match?(attributes, %Attribute{match: :value} = a) do
    value = attribute_value(attributes, a.attribute)
    value == a.value
  end

  def match?(attributes, %Attribute{match: :value_prefix} = a) do
    attributes
    |> attribute_value(a.attribute)
    |> String.starts_with?(a.value)
  end

  def match?(attributes, %Attribute{match: :value_suffix} = a) do
    attributes
    |> attribute_value(a.attribute)
    |> String.ends_with?(a.value)
  end

  def match?(attributes, %Attribute{match: :value_contains} = a) do
    attributes
    |> attribute_value(a.attribute)
    |> String.contains?(a.value)
  end

  def match?(_attributes, _selector) do
    false
  end

  defp attribute?(attributes, attribute) do
    attributes
    |> Enum.any?(fn({k, _}) -> k == attribute end)
  end

  defp attribute_with_prefix?(attributes, attribute) do
    attributes
    |> Enum.any?(fn({k, _}) -> String.starts_with?(k, attribute) end)
  end

  defp attribute_value(attributes, attribute) do
    {_attribute, value} = List.keyfind(attributes, attribute, 0, {nil, ""})
    value
  end
end
