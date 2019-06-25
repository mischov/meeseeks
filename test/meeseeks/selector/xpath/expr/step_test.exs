defmodule Meeseeks.Selector.XPath.Expr.StepTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]},
              :tuple_tree
            )

  test "step no matches" do
    expr = %Expr.Step{
      combinator: %Combinator.Self{selector: nil},
      predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
    }

    node = Document.get_node(@document, 1)
    context = %{}
    expected = []
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "step one match" do
    expr = %Expr.Step{
      combinator: %Combinator.Children{selector: nil},
      predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
    }

    node = Document.get_node(@document, 1)
    context = %{}
    expected = Document.get_nodes(@document, [2])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "step multiple matches" do
    expr = %Expr.Step{
      combinator: %Combinator.Descendants{selector: nil},
      predicates: [%Expr.NameTest{namespace: nil, tag: "page"}]
    }

    node = Document.get_node(@document, 1)
    context = %{}
    expected = Document.get_nodes(@document, [3, 5])
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
