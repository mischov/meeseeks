defmodule Meeseeks.Selector.ElementTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector

  test "namespace matches" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Selector.Element{
      namespace: "namespaced"}
    assert Selector.Element.match?(nil, element, selector)
  end

  test "namespace and tag matches" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Selector.Element{
      namespace: "namespaced",
      tag: "tag"}
    assert Selector.Element.match?(nil, element, selector)
  end

  test "tag matches namespaced tag" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Selector.Element{
      tag: "tag"}
    assert Selector.Element.match?(nil, element, selector)
  end

  test "tag matches unnamespaced tag" do
    element = %Document.Element{
      id: 1,
      tag: "tag"}
    selector = %Selector.Element{
      tag: "tag"
    }
    assert Selector.Element.match?(nil, element, selector)
  end

  test "tag doesn't match" do
    element = %Document.Element{
      id: 1,
      tag: "element"}
    selector = %Selector.Element{
      tag: "tag"
    }
    refute Selector.Element.match?(nil, element, selector)
  end

  test "id matches" do
    element = %Document.Element{
      id: 1,
      attributes: [{"id", "valid"}]}
    selector = %Selector.Element{
      attributes: [
	%Selector.Attribute{match: :value, attribute: "id", value: "valid"}
      ]
    }
    assert Selector.Element.match?(nil, element, selector)
  end

  test "class matches" do
    element = %Document.Element{
      id: 1,
      attributes: [{"class", "good bad ugly"}]}
    selector = %Selector.Element{
      attributes: [
	%Selector.Attribute{match: :class, attribute: "class", value: "good"}
      ]
    }
    assert Selector.Element.match?(nil, element, selector)
  end

  test "class doesn't match" do
    element = %Document.Element{
      id: 1,
      attributes: [{"class", "live laugh love"}]}
    selector = %Selector.Element{
      attributes: [
	%Selector.Attribute{match: :class, attribute: "class", value: "good"}
      ]
    }
    refute Selector.Element.match?(nil, element, selector)
  end

  test "tag, id, and class matches" do
    element = %Document.Element{
      id: 1,
      tag: "tag",
      attributes: [{"id", "valid"}, {"class", "match"}]}
    selector = %Selector.Element{
      tag: "tag",
      attributes: [
	%Selector.Attribute{match: :value, attribute: "id", value: "valid"},
	%Selector.Attribute{match: :class, attribute: "class", value: "match"}
      ]
    }
    assert Selector.Element.match?(nil, element, selector)
  end
end
