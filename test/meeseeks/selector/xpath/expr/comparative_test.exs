defmodule Meeseeks.Selector.XPath.Expr.ComparativeTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @document Meeseeks.parse(
              {"book", [], [{"chapter", [], [{"page", [], ["1"]}, {"page", [], ["2"]}]}]}
            )

  test "equal" do
    expr = %Expr.Comparative{
      op: :=,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "not equal" do
    expr = %Expr.Comparative{
      op: :!=,
      e1: %Expr.Number{value: 1},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "less than or equal to" do
    expr = %Expr.Comparative{
      op: :<=,
      e1: %Expr.Number{value: 1},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "less than" do
    expr = %Expr.Comparative{
      op: :<,
      e1: %Expr.Number{value: 1},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "greater than or equal to" do
    expr = %Expr.Comparative{
      op: :>=,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 1}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "greater than" do
    expr = %Expr.Comparative{
      op: :>,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: 1}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "greater than NaN" do
    expr = %Expr.Comparative{
      op: :>,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: :NaN}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "less than Infinity" do
    expr = %Expr.Comparative{
      op: :<,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: :Infinity}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "greater than -Infinity" do
    expr = %Expr.Comparative{
      op: :>,
      e1: %Expr.Number{value: 2},
      e2: %Expr.Number{value: :"-Infinity"}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "eq string" do
    expr = %Expr.Comparative{
      op: :=,
      e1: %Expr.Literal{value: "2"},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "comp string" do
    expr = %Expr.Comparative{
      op: :<,
      e1: %Expr.Literal{value: "1"},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "eq boolean" do
    expr = %Expr.Comparative{
      op: :=,
      e1: %Expr.Function{f: false, args: []},
      e2: %Expr.Number{value: 0}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "comp boolean" do
    expr = %Expr.Comparative{
      op: :<,
      e1: %Expr.Function{f: true, args: []},
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "eq nodeset" do
    expr = %Expr.Comparative{
      op: :=,
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
      e2: %Expr.Number{value: 2}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "comp nodeset" do
    expr = %Expr.Comparative{
      op: :>,
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
      e2: %Expr.Number{value: 3}
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "nodesets" do
    expr = %Expr.Comparative{
      op: :=,
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
      e2: %Expr.Path{
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
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false
    assert Expr.eval(expr, node, @document, context) == expected
  end
end
