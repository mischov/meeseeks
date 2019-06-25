defmodule Meeseeks.Selector.XPath.Expr.NegativeTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]},
              :tuple_tree
            )

  test "negate positive" do
    expr = %Expr.Negative{e: %Expr.Number{value: 2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = -2
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "negate negative" do
    expr = %Expr.Negative{e: %Expr.Number{value: -2}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = 2
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "negate NaN" do
    expr = %Expr.Negative{e: %Expr.Number{value: :NaN}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :NaN
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "negate Infinity" do
    expr = %Expr.Negative{e: %Expr.Number{value: :Infinity}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :"-Infinity"
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "negate -Infinity" do
    expr = %Expr.Negative{e: %Expr.Number{value: :"-Infinity"}}
    node = Document.get_node(@document, 4)
    context = %{}
    expected = :Infinity
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
