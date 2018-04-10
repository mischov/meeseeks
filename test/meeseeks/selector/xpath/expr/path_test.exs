defmodule Meeseeks.Selector.XPath.Expr.PathTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]}
            )

  test "absolute path" do
    expr = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Self{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "book"}]
        },
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
        }
      ],
      type: :abs
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = Document.get_nodes(@document, [2])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "relative path" do
    expr = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Self{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "page"}]
        }
      ],
      type: :rel
    }

    node = Document.get_node(@document, 3)
    context = %{}
    expected = Document.get_nodes(@document, [3])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "path no matches" do
    expr = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Self{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "missing"}]
        }
      ],
      type: :rel
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = []
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "path one match" do
    expr = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Self{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "chapter"}]
        }
      ],
      type: :rel
    }

    node = Document.get_node(@document, 2)
    context = %{}
    expected = Document.get_nodes(@document, [2])
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "path multiple matches" do
    expr = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.DescendantsOrSelf{selector: nil},
          predicates: [%Expr.NodeType{type: :node}]
        },
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [%Expr.NameTest{namespace: nil, tag: "page"}]
        }
      ],
      type: :abs
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = Document.get_nodes(@document, [3, 5])
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
