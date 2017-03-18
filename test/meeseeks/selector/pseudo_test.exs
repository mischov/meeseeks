defmodule Meeseeks.Selector.PseudoTest do
  use ExUnit.Case

  alias Meeseeks.Parser
  alias Meeseeks.Document
  alias Meeseeks.Selector.Element
  alias Meeseeks.Selector.Pseudo

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
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :first_child}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is not first-child" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :first_child}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first span is first-of-type" do
    element = Document.get_node(@test_document, 15)
    selector = %Pseudo{match: :first_of_type}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first span is last-child" do
    element = Document.get_node(@test_document, 15)
    selector = %Pseudo{match: :last_child}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is last-of-type" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :last_of_type}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is not last-child" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :last_child}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first span is not(p)" do
    element = Document.get_node(@test_document, 15)
    selector = %Pseudo{match: :not, args: [%Element{tag: "p"}]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first p is not not(p)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :not, args: [%Element{tag: "p"}]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first p is not(p:nth-child(even))" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :not,
                       args: [%Element{
                                 tag: "p",
                                 pseudos: [
                                   %Pseudo{
                                     match: :nth_child,
                                     args: ["even"]}]}]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-child(even)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: ["even"]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is not nth-child(even)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: ["even"]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-child(odd)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_child, args: ["odd"]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is not nth-child(odd)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: ["odd"]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-child(2)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: [2]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is not nth-child(2)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: [2]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-child(2n+0)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: [2, 0]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is not nth-child(2n+0)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: [2, 0]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-child(2n+1)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_child, args: [2, 1]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-child(0n+2)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: [0, 2]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is nth-child(3n)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: [3, 0]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is nth-child(-2n+3)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: [-2, 3]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-child(3n-2)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_child, args: [3, -2]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-last-child(even)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_last_child, args: ["even"]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first span is nth-last-child(1)" do
    element = Document.get_node(@test_document, 15)
    selector = %Pseudo{match: :nth_last_child, args: [1]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-last-child(3n+0)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_last_child, args: [3, 0]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-last-of-type(even)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_last_of_type, args: ["even"]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is nth-last-of-type(1)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_last_of_type, args: [1]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-last-of-type(3n+0)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_last_of_type, args: [3, 0]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "second p is nth-of-type(even)" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_of_type, args: ["even"]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "first p is nth-of-type(1)" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :nth_of_type, args: [1]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "third p is nth-of-type(3n+0)" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_of_type, args: [3, 0]}
    assert Pseudo.match?(@test_document, element, selector)
  end
end
