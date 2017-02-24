defmodule Meeseeks.Selector.PseudoTest do
  use ExUnit.Case

  alias Meeseeks.Parser
  alias Meeseeks.Document
  alias Meeseeks.Selector.Pseudo

  @test_html """
  <div>
    <p>1</p>
    <p>2</p>
    <p>3</p>
  </div>
  """

  @test_document Parser.parse(@test_html)

  test "nth child" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :nth_child, args: [2]}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "not nth child" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :nth_child, args: [2]}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "first child" do
    element = Document.get_node(@test_document, 6)
    selector = %Pseudo{match: :first_child}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "not first child" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :first_child}
    refute Pseudo.match?(@test_document, element, selector)
  end

  test "last child" do
    element = Document.get_node(@test_document, 12)
    selector = %Pseudo{match: :last_child}
    assert Pseudo.match?(@test_document, element, selector)
  end

  test "not last child" do
    element = Document.get_node(@test_document, 9)
    selector = %Pseudo{match: :last_child}
    refute Pseudo.match?(@test_document, element, selector)
  end
end
