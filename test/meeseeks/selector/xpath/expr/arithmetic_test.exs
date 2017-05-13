defmodule Meeseeks.Selector.XPath.Expr.ArithmeticTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
    {"book", [], [
        {"chapter", [], [
            {"page", [], ["1"]},
            {"page", [], ["2"]}]}]})

  test "add" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 4
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "infinity + 1" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Number{value: :Infinity},
      e2: %Expr.Number{value: 1}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :Infinity
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "subtract" do
    expr = %Expr.Arithmetic{
      op: :-,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 0
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "multiply" do
    expr = %Expr.Arithmetic{
      op: :*,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 4
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "divide" do
    expr = %Expr.Arithmetic{
      op: :div,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 1
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "divide by zero" do
    expr = %Expr.Arithmetic{
      op: :div,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 0}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :Infinity
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "mod" do
    expr = %Expr.Arithmetic{
      op: :mod,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 0
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "valid string" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Literal{value: "2"},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 4
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "invalid string" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Literal{value: "two"},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :NaN
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "boolean" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Function{f: :true, args: []},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 3
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "nodeset" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]},
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{ namespace: nil, tag: "page"}]}],
        type: :abs},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 3
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "nodeset empty" do
    expr = %Expr.Arithmetic{
      op: :+,
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]},
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{ namespace: nil, tag: "missing"}]}],
        type: :abs},
      e2: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :NaN
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
