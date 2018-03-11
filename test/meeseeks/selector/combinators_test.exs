defmodule Meeseeks.Selector.CombinatorsTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.Combinator

  @document Meeseeks.Parser.parse(
              {"html", [],
               [
                 {"head", [], []},
                 {"body", [],
                  [
                    {"div", [],
                     [
                       {"p", [], ["1"]},
                       {"p", [], ["2"]},
                       {"div", [], [{"p", [], ["3"]}, {"p", [], ["4"]}]},
                       {"p", [], ["5"]}
                     ]}
                  ]}
               ]}
            )

  test "parent" do
    combinator = %Combinator.Parent{}
    node = Document.get_node(@document, 5)
    expected = Document.get_node(@document, 4)

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "ancestors" do
    combinator = %Combinator.Ancestors{}
    node = Document.get_node(@document, 6)
    expected = Document.get_nodes(@document, [5, 4, 3, 1])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "ancestors or self" do
    combinator = %Combinator.AncestorsOrSelf{}
    node = Document.get_node(@document, 6)
    expected = Document.get_nodes(@document, [6, 5, 4, 3, 1])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "children" do
    combinator = %Combinator.Children{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [10, 12])
    assert Combinator.next(combinator, node, @document) == expected
  end

  test "child elements" do
    combinator = %Combinator.ChildElements{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [10, 12])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "descendants" do
    combinator = %Combinator.Descendants{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [10, 11, 12, 13])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "descendants or self" do
    combinator = %Combinator.DescendantsOrSelf{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [9, 10, 11, 12, 13])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "descendant elements" do
    combinator = %Combinator.DescendantElements{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [10, 12])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "previous siblings" do
    combinator = %Combinator.PreviousSiblings{}
    node = Document.get_node(@document, 9)
    expected = Document.get_nodes(@document, [5, 7])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "next siblings" do
    combinator = %Combinator.NextSiblings{}
    node = Document.get_node(@document, 7)
    expected = Document.get_nodes(@document, [9, 14])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "next sibling element" do
    combinator = %Combinator.NextSiblingElement{}
    node = Document.get_node(@document, 7)
    expected = Document.get_node(@document, 9)

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "next sibling elements" do
    combinator = %Combinator.NextSiblingElements{}
    node = Document.get_node(@document, 7)
    expected = Document.get_nodes(@document, [9, 14])

    assert Combinator.next(combinator, node, @document) == expected
  end

  test "self" do
    combinator = %Combinator.Self{}
    node = Document.get_node(@document, 7)
    expected = Document.get_node(@document, 7)

    assert Combinator.next(combinator, node, @document) == expected
  end
end
