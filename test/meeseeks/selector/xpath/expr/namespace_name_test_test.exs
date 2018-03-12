defmodule Meeseeks.Selector.XPath.Expr.NamespaceNameTestTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr

  test "any name" do
    expr = %Expr.NamespaceNameTest{name: "*"}
    node = "xml"
    document = nil
    context = nil
    expected = true

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "no namespace matching name" do
    expr = %Expr.NamespaceNameTest{name: "xml"}
    node = "xml"
    document = nil
    context = nil
    expected = true

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "no namespace non-matching name" do
    expr = %Expr.NamespaceNameTest{name: "xml"}
    node = "json"
    document = nil
    context = nil
    expected = false

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "empty namespace matching name" do
    expr = %Expr.NamespaceNameTest{namespace: "", name: "xml"}
    node = "xml"
    document = nil
    context = nil
    expected = true

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "empty namespace non-matching name" do
    expr = %Expr.NamespaceNameTest{namespace: "", name: "xml"}
    node = "json"
    document = nil
    context = nil
    expected = false

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "any namespace" do
    expr = %Expr.NamespaceNameTest{namespace: "xml"}
    node = "xml"
    document = nil
    context = nil
    expected = false

    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-attribute node doesn't match" do
    expr = %Expr.NamespaceNameTest{name: "xml"}
    node = %Document.Text{id: 1}
    document = nil
    context = nil
    expected = false

    assert Expr.eval(expr, node, document, context) == expected
  end
end
