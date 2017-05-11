defmodule Meeseeks.Selector.Element.AttributesTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector
  alias Meeseeks.Selector.Element.Attribute

  test "attribute exists" do
    selector = %Attribute.Attribute{attribute: "id"}
    element = element_with_attributes([{"id", "unique"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute exists, multiple attributes" do
    selector = %Attribute.Attribute{attribute: "id"}
    element = element_with_attributes([{"random", "attribute"}, {"id", "unique"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute with prefix exists" do
    selector = %Attribute.AttributePrefix{attribute: "data-"}
    element = element_with_attributes([{"data-model", "[1, 2, 3]"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has value" do
    selector = %Attribute.Value{attribute: "x", value: "y"}
    element = element_with_attributes([{"x", "y"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has value, multiple attributes" do
    selector = %Attribute.Value{attribute: "x", value: "y"}
    element = element_with_attributes([{"a", "b"}, {"x", "y"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has value that contains" do
    selector = %Attribute.ValueContains{attribute: "x", value: "bcd"}
    element = element_with_attributes([{"x", "abcde"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute is has value (value_dash version)" do
    selector = %Attribute.ValueDash{attribute: "lang", value: "en"}
    element = element_with_attributes([{"lang", "en"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute starts with value then dash" do
    selector = %Attribute.ValueDash{attribute: "lang", value: "en"}
    element = element_with_attributes([{"lang", "en-proper"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has whitespace separated values including value" do
    selector = %Attribute.ValueIncludes{attribute: "x", value: "b"}
    element = element_with_attributes([{"x", "a b c"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has value with prefix" do
    selector = %Attribute.ValuePrefix{attribute: "x", value: "ab"}
    element = element_with_attributes([{"x", "abcde"}])
    assert Selector.match(selector, element, nil, %{})
  end

  test "attribute has value with suffix" do
    selector = %Attribute.ValueSuffix{attribute: "x", value: "de"}
    element = element_with_attributes([{"x", "abcde"}])
    assert Selector.match(selector, element, nil, %{})
  end

  defp element_with_attributes(attributes) do
    %Document.Element{id: nil, attributes: attributes}
  end
end
