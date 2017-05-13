defmodule Meeseeks.Selector.XPath.CombinatorsTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Selector.{Combinator, XPath}

  @attributes [{"id", "unique"}, {"class", "a couple"}]
  @document Meeseeks.Parser.parse(
    {"awesome:div", @attributes, []})

  test "attributes" do
    combinator = %XPath.Combinator.Attributes{}
    node = Document.get_node(@document, 1)
    expected = @attributes
    assert Combinator.next(combinator, node, @document) == expected
  end

  test "namespaces" do
    combinator = %XPath.Combinator.Namespaces{}
    node = Document.get_node(@document, 1)
    expected = "awesome"
    assert Combinator.next(combinator, node, @document) == expected
  end
end
