defmodule Meeseeks.Selector.XPath.Expr.NameTestTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr

  test "any element" do
    expr = %Expr.NameTest{tag: "*"}
    node = %Document.Element{id: 0, namespace: "any", tag: "element"}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace any tag" do
    expr = %Expr.NameTest{namespace: "hello", tag: "*"}
    node = %Document.Element{id: 0, namespace: "hello", tag: "world"}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace any tag" do
    expr = %Expr.NameTest{namespace: "hello", tag: "*"}
    node = %Document.Element{id: 0, namespace: "goodbye", tag: "world"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace any tag without namespace" do
    expr = %Expr.NameTest{namespace: "hello", tag: "*"}
    node = %Document.Element{id: 0, tag: "element"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace no tag" do
    expr = %Expr.NameTest{namespace: "hello"}
    node = %Document.Element{id: 0, namespace: "hello", tag: "world"}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace no name" do
    expr = %Expr.NameTest{namespace: "hello"}
    node = %Document.Element{id: 0, namespace: "goodbye", tag: "world"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace no tag without namespace" do
    expr = %Expr.NameTest{namespace: "hello"}
    node = %Document.Element{id: 0, tag: "nope"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching tag" do
    expr = %Expr.NameTest{tag: "world"}
    node = %Document.Element{id: 0, namespace: "hello", tag: "world"}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching tag" do
    expr = %Expr.NameTest{tag: "world"}
    node = %Document.Element{id: 0, namespace: "goodmorning", tag: "vietnam"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace and tag" do
    expr = %Expr.NameTest{namespace: "hello", tag: "world"}
    node = %Document.Element{id: 0, namespace: "hello", tag: "world"}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace non-matching tag" do
    expr = %Expr.NameTest{namespace: "hello", tag: "world"}
    node = %Document.Element{id: 0, namespace: "hello", tag: "goodbye"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace matching tag" do
    expr = %Expr.NameTest{namespace: "hello", tag: "world"}
    node = %Document.Element{id: 0, namespace: "goodbye", tag: "world"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace and tag without namespace" do
    expr = %Expr.NameTest{namespace: "hello", tag: "world"}
    node = %Document.Element{id: 0, tag: "world"}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-element node doesn't match" do
    expr = %Expr.NameTest{tag: "world"}
    node = %Document.Text{id: 1}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end
end
