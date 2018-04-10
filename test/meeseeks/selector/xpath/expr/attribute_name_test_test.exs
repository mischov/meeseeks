defmodule Meeseeks.Selector.XPath.Expr.AttributeNameTestTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr

  test "any attribute" do
    expr = %Expr.AttributeNameTest{name: "*"}
    node = {"any:attribute", nil}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace any name" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "*"}
    node = {"hello:world", nil}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace any name" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "*"}
    node = {"goodbye:world", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace any name without namespace" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "*"}
    node = {"nope", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace no name" do
    expr = %Expr.AttributeNameTest{namespace: "hello"}
    node = {"hello:world", nil}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace no name" do
    expr = %Expr.AttributeNameTest{namespace: "hello"}
    node = {"goodbye:world", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace no name without namespace" do
    expr = %Expr.AttributeNameTest{namespace: "hello"}
    node = {"nope", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching name" do
    expr = %Expr.AttributeNameTest{name: "world"}
    node = {"hello:world", nil}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching name" do
    expr = %Expr.AttributeNameTest{name: "world"}
    node = {"goodmorning:vietnam", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace and name" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "world"}
    node = {"hello:world", nil}
    document = nil
    context = nil
    expected = true
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "matching namespace non-matching name" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "world"}
    node = {"hello:goodbye", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-matching namespace matching name" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "world"}
    node = {"goodbye:world", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "namespace and name without namespace" do
    expr = %Expr.AttributeNameTest{namespace: "hello", name: "world"}
    node = {"world", nil}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end

  test "non-attribute node doesn't match" do
    expr = %Expr.AttributeNameTest{name: "world"}
    node = %Document.Text{id: 1}
    document = nil
    context = nil
    expected = false
    assert Expr.eval(expr, node, document, context) == expected
  end
end
