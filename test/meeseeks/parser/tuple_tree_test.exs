defmodule Meeseeks.Parser.TupleTreeTest do
  use ExUnit.Case

  alias Meeseeks.{Error, Parser}

  @tuple_tree [
    {:doctype, "html", "", ""},
    {"html", [],
     [
       {"head", [], []},
       {"body", [],
        [
          {"div", [],
           [
             {"p", [], []},
             {"p", [], []},
             {"div", [], [{"p", [], []}, {"p", [], []}]},
             {"p", [], []}
           ]}
        ]}
     ]}
  ]

  @string "<!DOCTYPE html><html><head></head><body><div><p></p><p></p><div><p></p><p></p></div><p></p></div></body></html>"

  test "tuple tree parser makes same document as string parser" do
    assert Parser.parse(@tuple_tree) == Parser.parse(@string)
  end

  @invalid_tuple_tree_root_node {:ok, {"html", [], []}}

  test "tuple tree parser can't parse invalid root nodes" do
    {:error, %Error{} = error} = Parser.parse(@invalid_tuple_tree_root_node)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree root node"
  end

  @invalid_tuple_tree_node {"h1", [], [{:error, "NotANode"}]}

  test "tuple tree parser can't parse invalid nodes" do
    {:error, %Error{} = error} = Parser.parse(@invalid_tuple_tree_node)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end
end
