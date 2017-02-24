defmodule Meeseeks.Selector.AttributeTest do
  use ExUnit.Case

  alias Meeseeks.Selector.Attribute

  test "attribute exists" do
    attributes = [{"id", "unique"}]
    selector = %Attribute{match: :attribute, attribute: "id"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute exists, multiple attributes" do
    attributes = [{"random", "attribute"}, {"id", "unique"}]
    selector = %Attribute{match: :attribute, attribute: "id"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute with prefix exists" do
    attributes = [{"data-model", "[1, 2, 3]"}]
    selector = %Attribute{match: :attribute_prefix, attribute: "data-"}
    assert Attribute.match?(attributes, selector)
  end

  test "classes contain" do
    attributes = [{"class", "x y z"}]
      selector = %Attribute{match: :class, attribute: "class", value: "y"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute has value" do
    attributes = [{"x", "y"}]
      selector = %Attribute{match: :value, attribute: "x", value: "y"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute has value, multiple attributes" do
    attributes = [{"a", "b"}, {"x", "y"}]
      selector = %Attribute{match: :value, attribute: "x", value: "y"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute has value with prefix" do
    attributes = [{"x", "abcde"}]
      selector = %Attribute{match: :value_prefix, attribute: "x", value: "ab"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute has value with suffix" do
    attributes = [{"x", "abcde"}]
      selector = %Attribute{match: :value_suffix, attribute: "x", value: "de"}
    assert Attribute.match?(attributes, selector)
  end

  test "attribute has value that contains" do
    attributes = [{"x", "abcde"}]
      selector = %Attribute{match: :value_contains, attribute: "x", value: "bcd"}
    assert Attribute.match?(attributes, selector)
  end
end
