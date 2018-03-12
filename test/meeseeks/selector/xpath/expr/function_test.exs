defmodule Meeseeks.Selector.XPath.Expr.FunctionTest do
  use ExUnit.Case

  alias Meeseeks.{Context, Document}
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.XPath.Expr

  @nodes Context.nodes_key()
  @document Meeseeks.Parser.parse(
              {"html", [],
               [
                 {"head", [], []},
                 {"body", [],
                  [
                    {"div", [],
                     [
                       {"p", [], ["1"]},
                       {"special:p", [], ["2"]},
                       {"div", [], [{"p", [], ["3"]}, {"p", [], ["4"]}]},
                       {"p", [], ["5"]}
                     ]}
                  ]}
               ]}
            )

  # last

  test "last no args" do
    expr = %Expr.Function{
      f: :last,
      args: []
    }

    node = Document.get_node(@document, 4)
    context = %{@nodes => Document.get_nodes(@document)}
    expected = 15

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # position

  test "position no args" do
    expr = %Expr.Function{
      f: :position,
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{@nodes => Document.get_nodes(@document)}
    expected = 7

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # count

  test "count no args" do
    expr = %Expr.Function{
      f: :count,
      args: [
        %Expr.Path{
          steps: [
            %Expr.Step{
              combinator: %Combinator.DescendantsOrSelf{selector: nil},
              predicates: [%Expr.NodeType{type: :node}]
            },
            %Expr.Step{
              combinator: %Combinator.Children{selector: nil},
              predicates: [%Expr.NameTest{namespace: nil, tag: "p"}]
            }
          ],
          type: :abs
        }
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 5

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # local-name

  test "local-name no args" do
    expr = %Expr.Function{
      f: :"local-name",
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "p"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "local-name one arg" do
    expr = %Expr.Function{
      f: :"local-name",
      args: [
        %Expr.Path{
          steps: [
            %Expr.Step{
              combinator: %Combinator.Self{selector: nil},
              predicates: [%Expr.NameTest{namespace: nil, tag: "p"}]
            }
          ],
          type: :rel
        }
      ]
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "p"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # namespace-uri

  test "namespace-uri no args" do
    expr = %Expr.Function{
      f: :"namespace-uri",
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "special"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "namespace-uri one arg" do
    expr = %Expr.Function{
      f: :"namespace-uri",
      args: [
        %Expr.Path{
          steps: [
            %Expr.Step{
              combinator: %Combinator.Self{selector: nil},
              predicates: [%Expr.NameTest{namespace: nil, tag: "p"}]
            }
          ],
          type: :rel
        }
      ]
    }

    node = Document.get_node(@document, 5)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # name

  test "name no args" do
    expr = %Expr.Function{
      f: :name,
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "special:p"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "name one arg" do
    expr = %Expr.Function{
      f: :name,
      args: [
        %Expr.Path{
          steps: [
            %Expr.Step{
              combinator: %Combinator.Self{selector: nil},
              predicates: [%Expr.NameTest{namespace: nil, tag: "p"}]
            }
          ],
          type: :rel
        }
      ]
    }

    node = Document.get_node(@document, 5)
    context = %{}
    expected = "p"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # string

  test "string no args" do
    expr = %Expr.Function{
      f: :string,
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "2"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "string one arg" do
    expr = %Expr.Function{
      f: :string,
      args: [%Expr.Number{value: :Infinity}]
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = "Infinity"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # concat

  test "concat three args" do
    expr = %Expr.Function{
      f: :concat,
      args: [
        %Expr.Number{value: :Infinity},
        %Expr.Literal{value: " plus "},
        %Expr.Number{value: 1}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "Infinity plus 1"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # starts-with

  test "starts-with two args true" do
    expr = %Expr.Function{
      f: :"starts-with",
      args: [
        %Expr.Literal{value: "hello"},
        %Expr.Literal{value: "hell"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "starts-with two args false" do
    expr = %Expr.Function{
      f: :"starts-with",
      args: [
        %Expr.Literal{value: "hello"},
        %Expr.Literal{value: "no"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # contains

  test "contains two args true" do
    expr = %Expr.Function{
      f: :contains,
      args: [
        %Expr.Literal{value: "hello"},
        %Expr.Literal{value: "ello"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true
    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "contains two args false" do
    expr = %Expr.Function{
      f: :contains,
      args: [
        %Expr.Literal{value: "hello"},
        %Expr.Literal{value: "no"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # substring-before

  test "substring-before two args" do
    expr = %Expr.Function{
      f: :"substring-before",
      args: [
        %Expr.Literal{value: "Hello, World!"},
        %Expr.Literal{value: ","}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "Hello"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # substring-after

  test "substring-after two args" do
    expr = %Expr.Function{
      f: :"substring-after",
      args: [
        %Expr.Literal{value: "Hello, World!"},
        %Expr.Literal{value: ","}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = " World!"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # substring

  test "substring two args" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: "2"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "2345"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring two args NaN" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: :NaN}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring two args Infinity" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: :Infinity}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring two args -Infinity" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: :"-Infinity"}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "12345"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args simple" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: 2},
        %Expr.Number{value: 3}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "234"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args any NaN" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: 2},
        %Expr.Number{value: :NaN}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args Infinity start" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: :Infinity},
        %Expr.Number{value: 5}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args neg start len too short" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: -3},
        %Expr.Number{value: 3}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args neg start and len" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: -3},
        %Expr.Number{value: 5}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "1"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args neg start and Infinity len" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: -3},
        %Expr.Number{value: :Infinity}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "12345"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args -Infinity start and Infinity len" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: :"-Infinity"},
        %Expr.Number{value: :Infinity}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "12345"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "substring three args valid start and neg len" do
    expr = %Expr.Function{
      f: :substring,
      args: [
        %Expr.Literal{value: "12345"},
        %Expr.Number{value: 2},
        %Expr.Number{value: -1}
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = ""

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # string-length

  test "string-length no args" do
    expr = %Expr.Function{
      f: :"string-length",
      args: []
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 5

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "string-length one arg" do
    expr = %Expr.Function{
      f: :"string-length",
      args: [%Expr.Literal{value: "Hi"}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 2

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # normalize-space

  test "normalize-space no args" do
    expr = %Expr.Function{
      f: :"normalize-space",
      args: []
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "12345"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "normalize-space one arg" do
    expr = %Expr.Function{
      f: :"normalize-space",
      args: [%Expr.Literal{value: "     Hello,     World!  "}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = "Hello, World!"

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # boolean

  test "boolean one arg true" do
    expr = %Expr.Function{
      f: :boolean,
      args: [%Expr.Literal{value: "Hi"}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "boolean one arg false" do
    expr = %Expr.Function{
      f: :boolean,
      args: [%Expr.Literal{value: ""}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # not

  test "not one arg" do
    expr = %Expr.Function{
      f: :not,
      args: [
        %Expr.Function{
          f: :boolean,
          args: [%Expr.Literal{value: ""}]
        }
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # true

  test "true no args" do
    expr = %Expr.Function{
      f: true,
      args: []
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = true

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # false

  test "false no args" do
    expr = %Expr.Function{
      f: false,
      args: []
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = false

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # number

  test "number no args" do
    expr = %Expr.Function{
      f: :number,
      args: []
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = 2

    assert Expr.eval(expr, node, @document, context) == expected
  end

  test "number one arg" do
    expr = %Expr.Function{
      f: :number,
      args: [
        %Expr.Function{f: false, args: []}
      ]
    }

    node = Document.get_node(@document, 7)
    context = %{}
    expected = 0

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # sum

  test "sum one arg" do
    expr = %Expr.Function{
      f: :sum,
      args: [
        %Expr.Path{
          steps: [
            %Expr.Step{
              combinator: %Combinator.DescendantsOrSelf{selector: nil},
              predicates: [%Expr.NodeType{type: :node}]
            },
            %Expr.Step{
              combinator: %Combinator.Children{selector: nil},
              predicates: [%Expr.NameTest{namespace: nil, tag: "p"}]
            }
          ],
          type: :abs
        }
      ]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 15

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # floor

  test "floor one arg" do
    expr = %Expr.Function{
      f: :floor,
      args: [%Expr.Number{value: 2.6}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 2

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # ceiling

  test "ceiling one arg" do
    expr = %Expr.Function{
      f: :ceiling,
      args: [%Expr.Number{value: 2.5}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 3

    assert Expr.eval(expr, node, @document, context) == expected
  end

  # round

  test "round one arg" do
    expr = %Expr.Function{
      f: :round,
      args: [%Expr.Number{value: 2.4}]
    }

    node = Document.get_node(@document, 4)
    context = %{}
    expected = 2

    assert Expr.eval(expr, node, @document, context) == expected
  end
end
