defmodule Meeseeks.DocumentTest do
  use ExUnit.Case

  alias Meeseeks.{Document, Error}

  @tree [
    {:doctype, "html", "", ""},
    {"html", [],
     [
       {"head", [], []},
       {"body", [],
        [
          {"div", [{"attr", "1 \"2\" 3"}],
           [
             {"p", [], []},
             {"p", [], []},
             {"div", [], [{"p", [], []}, {"p", [], []}]},
             {"p", [], []}
           ]}
        ]}
     ]}
  ]
  @document Meeseeks.Parser.parse(@tree, :tuple_tree)

  test "html" do
    expected =
      "<!DOCTYPE html><html><head></head><body><div attr='1 \"2\" 3'><p></p><p></p><div><p></p><p></p></div><p></p></div></body></html>"

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

  test "get_root_ids" do
    assert Document.get_root_ids(@document) == [1, 2]
  end

  test "get_root_nodes" do
    expected = [
      %Meeseeks.Document.Doctype{id: 1, name: "html", public: "", system: ""},
      %Meeseeks.Document.Element{id: 2, tag: "html", children: [3, 4]}
    ]

    assert Document.get_root_nodes(@document) == expected
  end

  test "get_node_ids" do
    assert Document.get_node_ids(@document) == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  end

  test "delete_node results in the proper descendants" do
    descendants_after_deletion =
      @document
      |> Document.delete_node(8)
      |> Document.descendants(5)

    assert descendants_after_deletion == [6, 7, 11]
  end

  test "delete_node retains the proper keys" do
    node_ids_after_deletion =
      @document
      |> Document.delete_node(8)
      |> Document.get_node_ids()

    assert node_ids_after_deletion == [1, 2, 3, 4, 5, 6, 7, 11]
  end

  test "delete_node retains non-element keys" do
    node_ids_after_deletion =
      "<!DOCTYPE html><html><head></head><body><div><p>hello world</p><p></p><div><p></p><p></p></div><p></p></div></body></html>"
      |> Meeseeks.Parser.parse()
      |> Document.delete_node(9)
      |> Document.get_node_ids()

    assert node_ids_after_deletion == [1, 2, 3, 4, 5, 6, 7, 8, 12]
  end

  test "delete_node with a root node" do
    root_ids_after_deletion =
      @document
      |> Document.delete_node(1)
      |> Document.get_root_ids()

    assert root_ids_after_deletion == [2]
  end

  test "raise if attempting to provide node_id that doesn't exist in document" do
    assert_raise Error, ~r/Type: :document\n\n  Reason: :unknown_node/, fn ->
      Document.children(@document, 9000)
    end
  end
end
