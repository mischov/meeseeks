defmodule Meeseeks.Selector.RootTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector
  alias Meeseeks.Selector.{Element, Root}

  test "root matches" do
    element = %Document.Element{id: 1, namespace: "root", tag: "element"}
    selector = %Root{}
    assert Selector.match(selector, element, nil, %{})
  end

  test "not root doesn't match" do
    element = %Document.Element{parent: 1, id: 2, tag: "tag"}
    selector = %Root{}
    refute Selector.match(selector, element, nil, %{})
  end

  test "root with selector matches" do
    element = %Document.Element{id: 1, namespace: "root", tag: "element"}
    selector = %Root{selectors: [%Element.Namespace{value: "root"}]}
    assert Selector.match(selector, element, nil, %{})
  end

  test "not root with selector doesn't match" do
    element = %Document.Element{parent: 1, id: 2, tag: "tag"}
    selector = %Root{selectors: [%Element.Namespace{value: "root"}]}
    refute Selector.match(selector, element, nil, %{})
  end

  test "root with selector doesn't match" do
    element = %Document.Element{id: 1, namespace: "root", tag: "element"}
    selector = %Root{selectors: [%Element.Namespace{value: "not-root"}]}
    refute Selector.match(selector, element, nil, %{})
  end
end
