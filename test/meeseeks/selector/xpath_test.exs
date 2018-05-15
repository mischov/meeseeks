defmodule Meeseeks.Selector.XPathTest do
  use ExUnit.Case

  alias Meeseeks.Error
  alias Meeseeks.Selector.{Combinator, Element, Node, Root, XPath}
  alias Meeseeks.Selector.XPath.Expr

  test "single segment wildcard selector" do
    xpath = "*"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: nil,
          filters: nil,
          selectors: [%Element.Tag{value: "*"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "single segment abs selector" do
    xpath = "/root"

    expected = %Root{
      combinator: nil,
      filters: nil,
      selectors: [%Element.Tag{value: "root"}]
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "single segment rel selector" do
    xpath = "node"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: nil,
          filters: nil,
          selectors: [%Element.Tag{value: "node"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "single segment selector with predicate" do
    xpath = "node[2]"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: nil,
          filters: [%XPath.Predicate{e: %Expr.Predicate{e: %Expr.Number{value: 2}}}],
          selectors: [%Element.Tag{value: "node"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "single segment selector with axis" do
    xpath = "descendant::node"

    expected = %Element{
      combinator: %Combinator.Descendants{
        selector: %Element{
          combinator: nil,
          filters: nil,
          selectors: [%Element.Tag{value: "node"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "multiple segment abs selector" do
    xpath = "/root/child"

    expected = %Root{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: nil,
          filters: nil,
          selectors: [%Element.Tag{value: "child"}]
        }
      },
      filters: nil,
      selectors: [%Element.Tag{value: "root"}]
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "multiple segment rel selector" do
    xpath = "node/child"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: %Combinator.Children{
            selector: %Element{
              combinator: nil,
              filters: nil,
              selectors: [%Element.Tag{value: "child"}]
            }
          },
          filters: nil,
          selectors: [%Element.Tag{value: "node"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "multiple segment selector with predicates" do
    xpath = "node[4]/child[last()]"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: %Combinator.Children{
            selector: %Element{
              combinator: nil,
              filters: [
                %XPath.Predicate{e: %Expr.Predicate{e: %Expr.Function{args: [], f: :last}}}
              ],
              selectors: [%Element.Tag{value: "child"}]
            }
          },
          filters: [%XPath.Predicate{e: %Expr.Predicate{e: %Expr.Number{value: 4}}}],
          selectors: [%Element.Tag{value: "node"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "abbreviated parent selector" do
    xpath = "../child"

    expected = %Node{
      combinator: %Combinator.Parent{
        selector: %Element{
          combinator: %Combinator.Children{
            selector: %Element{
              combinator: nil,
              filters: nil,
              selectors: [%Element.Tag{value: "child"}]
            }
          },
          filters: nil,
          selectors: []
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "abbreviated root descendant-or-self selector" do
    xpath = "//child"

    expected = %Element{
      combinator: %Combinator.Children{
        selector: %Element{
          combinator: nil,
          filters: nil,
          selectors: [%Element.Tag{value: "child"}]
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "abbreviated node descendant-or-self selector" do
    xpath = ".//child"

    expected = %Node{
      combinator: %Combinator.DescendantsOrSelf{
        selector: %Element{
          combinator: %Combinator.Children{
            selector: %Element{
              combinator: nil,
              filters: nil,
              selectors: [%Element.Tag{value: "child"}]
            }
          },
          filters: nil,
          selectors: []
        }
      },
      filters: nil,
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "abbreviated attribute selector" do
    xpath = "@*"

    expected = %Node{
      combinator: %XPath.Combinator.Attributes{
        selector: %Node{
          combinator: nil,
          selectors: [%XPath.Predicate{e: %Expr.AttributeNameTest{name: "*", namespace: nil}}]
        }
      },
      selectors: []
    }

    assert XPath.compile_selectors(xpath) == expected
  end

  test "simple union selector" do
    xpath = "/root|./child"

    expected = [
      %Root{combinator: nil, filters: nil, selectors: [%Element.Tag{value: "root"}]},
      %Element{
        combinator: %Combinator.Children{
          selector: %Element{
            combinator: nil,
            filters: nil,
            selectors: [%Element.Tag{value: "child"}]
          }
        },
        filters: nil,
        selectors: []
      }
    ]

    assert XPath.compile_selectors(xpath) == expected
  end

  test "complex union selector" do
    xpath = "node[4]/child[last()]|/comment()"

    expected = [
      %Element{
        combinator: %Combinator.Children{
          selector: %Element{
            combinator: %Combinator.Children{
              selector: %Element{
                combinator: nil,
                filters: [
                  %XPath.Predicate{e: %Expr.Predicate{e: %Expr.Function{args: [], f: :last}}}
                ],
                selectors: [%Element.Tag{value: "child"}]
              }
            },
            filters: [%XPath.Predicate{e: %Expr.Predicate{e: %Expr.Number{value: 4}}}],
            selectors: [%Element.Tag{value: "node"}]
          }
        },
        filters: nil,
        selectors: []
      },
      %Root{
        combinator: nil,
        filters: nil,
        selectors: [%XPath.Predicate{e: %Expr.NodeType{type: :comment}}]
      }
    ]

    assert XPath.compile_selectors(xpath) == expected
  end

  test "no top-level filters" do
    xpath = "(this|that)[2]"

    assert_raise Error,
                 ~r/XPath filter expressions are not supported outside of predicates/,
                 fn ->
                   XPath.compile_selectors(xpath)
                 end
  end
end
