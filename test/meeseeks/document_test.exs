defmodule Meeseeks.DocumentTest do
  use ExUnit.Case

  alias Meeseeks.Document

  @tree [
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
  @document Meeseeks.Parser.parse(@tree)

  test "html" do
    expected =
      "<!DOCTYPE html><html><head></head><body><div><p></p><p></p><div><p></p><p></p></div><p></p></div></body></html>"

    assert Document.html(@document) == expected
  end

  test "tree" do
    assert Document.tree(@document) == @tree
  end

  test "html node is element?" do
    assert Document.element?(@document, 2)
  end

  test "parent" do
    assert Document.parent(@document, 8) == 5
  end

  test "no parent" do
    assert Document.parent(@document, 2) == nil
  end

  test "ancestors" do
    assert Document.ancestors(@document, 8) == [5, 4, 2]
  end

  test "no ancestors" do
    assert Document.ancestors(@document, 2) == []
  end

  test "children" do
    assert Document.children(@document, 5) == [6, 7, 8, 11]
  end

  test "descendants" do
    assert Document.descendants(@document, 5) == [6, 7, 8, 9, 10, 11]
  end

  test "siblings" do
    assert Document.siblings(@document, 7) == [6, 7, 8, 11]
  end

  test "previous_siblings" do
    assert Document.previous_siblings(@document, 8) == [6, 7]
  end

  test "next_siblings" do
    assert Document.next_siblings(@document, 7) == [8, 11]
  end

  test "get_root_nodes" do
    expected = [
      %Meeseeks.Document.Doctype{id: 1, name: "html", public: "", system: ""},
      %Meeseeks.Document.Element{id: 2, tag: "html", children: [3, 4]}
    ]

    assert Document.get_root_nodes(@document) == expected
  end
end
