defmodule Meeseeks.Selector.XPath.Expr.UnionTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]}
            )

  test "union both match" do
    expr = %Expr.Union{
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.Self{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "book"}]
          }
        ],
        type: :abs
      },
      e2: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]
          },
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
          }
        ],
        type: :abs
      }
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = Document.get_nodes(@document, [1, 2])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "union one matches" do
    expr = %Expr.Union{
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.Self{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "textbook"}]
          }
        ],
        type: :abs
      },
      e2: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]
          },
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
          }
        ],
        type: :abs
      }
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = Document.get_nodes(@document, [2])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "union neither matches" do
    expr = %Expr.Union{
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.Self{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "textbook"}]
          }
        ],
        type: :abs
      },
      e2: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]
          },
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "lesson"}]
          }
        ],
        type: :abs
      }
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = []
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
