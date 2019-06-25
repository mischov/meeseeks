defmodule Meeseeks.Selector.XPath.Expr.BooleanTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]},
              :tuple_tree
            )

  test "true or true" do
    expr = %Expr.Boolean{
      op: :or,
      e1: %Expr.Function{f: true, args: []},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "false or true" do
    expr = %Expr.Boolean{
      op: :or,
      e1: %Expr.Function{f: false, args: []},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "false or false" do
    expr = %Expr.Boolean{
      op: :or,
      e1: %Expr.Function{f: false, args: []},
      e2: %Expr.Function{f: false, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "true and true" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Function{f: true, args: []},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "true and false" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Function{f: true, args: []},
      e2: %Expr.Function{f: false, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "false and true" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Function{f: false, args: []},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "true string" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Literal{value: "hello"},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "false string" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Literal{value: ""},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "number true" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "number false" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Number{value: 0},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "NaN" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Number{value: :NaN},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "Infinity" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Number{value: :Infinity},
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "nodeset" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Path{
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
      },
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "nodeset empty" do
    expr = %Expr.Boolean{
      op: :and,
      e1: %Expr.Path{
        steps: [
          %Expr.Step{
            combinator: %Combinator.DescendantsOrSelf{selector: nil},
            predicates: [%Expr.NodeType{type: :node}]
          },
          %Expr.Step{
            combinator: %Combinator.Children{selector: nil},
            predicates: [%Expr.NameTest{namespace: nil, tag: "missing"}]
          }
        ],
        type: :abs
      },
      e2: %Expr.Function{f: true, args: []}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
