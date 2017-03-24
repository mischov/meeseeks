defmodule Meeseeks.Selector.ElementTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector
  alias Meeseeks.Selector.Element

  test "namespace matches" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Element{
      selectors: [
        %Element.Namespace{value: "namespaced"}]}
    assert Selector.match?(selector, element, nil)
  end

  test "namespace and tag matches" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Element{
      selectors: [
        %Element.Namespace{value: "namespaced"},
        %Element.Tag{value: "tag"}]}
    assert Selector.match?(selector, element, nil)
  end

  test "tag matches namespaced tag" do
    element = %Document.Element{
      id: 1,
      namespace: "namespaced",
      tag: "tag"}
    selector = %Element{
      selectors: [
        %Element.Tag{value: "tag"}]}
    assert Selector.match?(selector, element, nil)
  end

  test "tag matches unnamespaced tag" do
    element = %Document.Element{
      id: 1,
      tag: "tag"}
    selector = %Element{
      selectors: [
        %Element.Tag{value: "tag"}]}
    assert Selector.match?(selector, element, nil)
  end

  test "tag doesn't match" do
    element = %Document.Element{
      id: 1,
      tag: "element"}
    selector = %Element{
      selectors: [
        %Element.Tag{value: "tag"}]}
    refute Selector.match?(selector, element, nil)
  end

  test "namespace, tag, id, and class matches" do
    element = %Document.Element{
      id: 1,
      namespace: "some",
      tag: "tag",
      attributes: [{"id", "valid"}, {"class", "match"}]}
    selector = %Element{
      selectors: [
        %Element.Namespace{value: "some"},
        %Element.Tag{value: "tag"},
        %Element.Attribute.Value{attribute: "id", value: "valid"},
        %Element.Attribute.ValueIncludes{attribute: "class", value: "match"}]}
    assert Selector.match?(selector, element, nil)
  end
end
