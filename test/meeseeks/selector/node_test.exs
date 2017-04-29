defmodule Meeseeks.Selector.NodeTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector
  alias Meeseeks.Selector.{Element, Node}

  test "node matches comment" do
    element = %Document.Comment{
      id: 1,
      content: "Root comment"}
    selector = %Node{}
    assert Selector.match?(selector, element, nil)
  end

  test "node matches data" do
    element = %Document.Data{
      parent: 1,
      id: 2,
      content: "Am script I guess?"}
    selector = %Node{}
    assert Selector.match?(selector, element, nil)
  end

  test "node matches doctype" do
    element = %Document.Doctype{
      id: 1}
    selector = %Node{}
    assert Selector.match?(selector, element, nil)
  end

  test "node matches element" do
    element = %Document.Element{
      parent: 1,
      id: 2,
      namespace: "random",
      tag: "element"}
    selector = %Node{}
    assert Selector.match?(selector, element, nil)
  end

  test "node matches text" do
    element = %Document.Text{
      parent: 1,
      id: 2,
      content: "Hi"}
    selector = %Node{}
    assert Selector.match?(selector, element, nil)
  end

  test "element with selector match" do
    element = %Document.Element{
      id: 1,
      namespace: "root",
      tag: "element"}
    selector = %Node{
      selectors: [
        %Element.Namespace{value: "root"}]}
    assert Selector.match?(selector, element, nil)
  end

  test "element with selector doesn't match" do
    element = %Document.Element{
      id: 1,
      namespace: "root",
      tag: "element"}
    selector = %Node{
      selectors: [
        %Element.Namespace{value: "not-root"}]}
    refute Selector.match?(selector, element, nil)
  end
end
