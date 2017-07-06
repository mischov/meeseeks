defmodule Meeseeks.Parser.TupleTreeTest do
  use ExUnit.Case

  alias Meeseeks.Parser

  @tuple_tree [
    {:doctype, "html", "", ""},
    {"html", [], [
        {"head", [], []},
        {"body", [], [
            {"div", [], [
                {"p", [], []},
                {"p", [], []},
                {"div", [], [
                    {"p", [], []},
                    {"p", [], []}]},
                {"p", [], []}]}]}]}]

  @string "<!DOCTYPE html><html><head></head><body><div><p></p><p></p><div><p></p><p></p></div><p></p></div></body></html>"

  test "tuple tree parser makes same document as string parser" do
    assert Parser.parse(@tuple_tree) == Parser.parse(@string)
  end
end
