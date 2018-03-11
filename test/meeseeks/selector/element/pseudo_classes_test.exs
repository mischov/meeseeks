defmodule Meeseeks.Selector.PseudoTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Parser
  alias Meeseeks.Selector
  alias Meeseeks.Selector.Element
  alias Meeseeks.Selector.Element.PseudoClass

  @test_html """
  <div>
    <p>1</p>
    <p>2</p>
    <p>3</p>
    <span>4</span>
  </div>
  """

  @test_document Parser.parse(@test_html)

  test "first p is first-child" do
    selector = %PseudoClass.FirstChild{}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is not first-child" do
    selector = %PseudoClass.FirstChild{}
    element = Document.get_node(@test_document, 9)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "first span is first-of-type" do
    selector = %PseudoClass.FirstOfType{}
    element = Document.get_node(@test_document, 15)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first span is last-child" do
    selector = %PseudoClass.LastChild{}
    element = Document.get_node(@test_document, 15)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is last-of-type" do
    selector = %PseudoClass.LastOfType{}
    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is not last-child" do
    selector = %PseudoClass.LastChild{}
    element = Document.get_node(@test_document, 12)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "first span is not(p)" do
    selector = %PseudoClass.Not{
      args: [
        [%Element{selectors: [%Element.Tag{value: "p"}]}]
      ]
    }

    element = Document.get_node(@test_document, 15)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first p is not not(p)" do
    selector = %PseudoClass.Not{
      args: [
        [%Element{selectors: [%Element.Tag{value: "p"}]}]
      ]
    }

    element = Document.get_node(@test_document, 6)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "first p is not(p:nth-child(even))" do
    selector = %PseudoClass.Not{
      args: [
        [%Element{selectors: [%PseudoClass.NthChild{args: ["even"]}]}]
      ]
    }

    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is not(p:nth-child(1), p:nth-child(2))" do
    selector = %PseudoClass.Not{
      args: [
        [
          %Element{selectors: [%PseudoClass.NthChild{args: [1]}]},
          %Element{selectors: [%PseudoClass.NthChild{args: [2]}]}
        ]
      ]
    }

    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-child(even)" do
    selector = %PseudoClass.NthChild{args: ["even"]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is not nth-child(even)" do
    selector = %PseudoClass.NthChild{args: ["even"]}
    element = Document.get_node(@test_document, 12)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-child(odd)" do
    selector = %PseudoClass.NthChild{args: ["odd"]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is not nth-child(odd)" do
    selector = %PseudoClass.NthChild{args: ["odd"]}
    element = Document.get_node(@test_document, 9)
    refute Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-child(2)" do
    selector = %PseudoClass.NthChild{args: [2]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is not nth-child(2)" do
    selector = %PseudoClass.NthChild{args: [2]}
    element = Document.get_node(@test_document, 12)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-child(2n+0)" do
    selector = %PseudoClass.NthChild{args: [2, 0]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is not nth-child(2n+0)" do
    selector = %PseudoClass.NthChild{args: [2, 0]}
    element = Document.get_node(@test_document, 12)

    refute Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-child(2n+1)" do
    selector = %PseudoClass.NthChild{args: [2, 1]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-child(0n+2)" do
    selector = %PseudoClass.NthChild{args: [0, 2]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is nth-child(3n)" do
    selector = %PseudoClass.NthChild{args: [3, 0]}
    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is nth-child(-2n+3)" do
    selector = %PseudoClass.NthChild{args: [-2, 3]}
    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-child(3n-2)" do
    selector = %PseudoClass.NthChild{args: [3, -2]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-last-child(even)" do
    selector = %PseudoClass.NthLastChild{args: ["even"]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first span is nth-last-child(1)" do
    selector = %PseudoClass.NthLastChild{args: [1]}
    element = Document.get_node(@test_document, 15)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-last-child(3n+0)" do
    selector = %PseudoClass.NthLastChild{args: [3, 0]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-last-of-type(even)" do
    selector = %PseudoClass.NthLastOfType{args: ["even"]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is nth-last-of-type(1)" do
    selector = %PseudoClass.NthLastOfType{args: [1]}
    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-last-of-type(3n+0)" do
    selector = %PseudoClass.NthLastOfType{args: [3, 0]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "second p is nth-of-type(even)" do
    selector = %PseudoClass.NthOfType{args: ["even"]}
    element = Document.get_node(@test_document, 9)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "first p is nth-of-type(1)" do
    selector = %PseudoClass.NthOfType{args: [1]}
    element = Document.get_node(@test_document, 6)

    assert Selector.match(selector, element, @test_document, %{})
  end

  test "third p is nth-of-type(3n+0)" do
    selector = %PseudoClass.NthOfType{args: [3, 0]}
    element = Document.get_node(@test_document, 12)

    assert Selector.match(selector, element, @test_document, %{})
  end
end
