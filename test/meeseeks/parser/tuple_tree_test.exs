defmodule Meeseeks.Parser.TupleTreeTest do
  use ExUnit.Case

  alias Meeseeks.{Document, Error, Parser}

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

  test "creates same document as string parser" do
    assert Parser.parse(@tuple_tree, :tuple_tree) == Parser.parse(@string)
  end

  test "cannot parse invalid root nodes" do
    {:error, %Error{} = error} = Parser.parse({:ok, {"html", [], []}}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse invalid nodes" do
    {:error, %Error{} = error} = Parser.parse({"h1", [], [{:error, "NotANode"}]}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # Comment

  test "can parse valid comment node" do
    assert match?(%Document{}, Parser.parse({:comment, "valid"}, :tuple_tree))
  end

  test "cannot parse comment node with invalid comment" do
    {:error, %Error{} = error} = Parser.parse({:comment, :invalid}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # Data

  test "can parse valid data node" do
    assert match?(%Document{}, Parser.parse({"script", [], ["valid"]}, :tuple_tree))
  end

  test "cannot parse data node with invalid data" do
    {:error, %Error{} = error} = Parser.parse({"script", [], [:invalid]}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # Doctype

  test "can parse valid doctype node" do
    assert match?(%Document{}, Parser.parse({:doctype, "valid", "valid", "valid"}, :tuple_tree))
  end

  test "cannot parse doctype node with invalid name" do
    {:error, %Error{} = error} = Parser.parse({:doctype, :invalid, "valid", "valid"}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse doctype node with invalid public" do
    {:error, %Error{} = error} = Parser.parse({:doctype, "valid", :invalid, "valid"}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse doctype node with invalid system" do
    {:error, %Error{} = error} = Parser.parse({:doctype, "valid", "valid", :invalid}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # Element

  test "can parse valid element node" do
    assert match?(%Document{}, Parser.parse({"valid", [{"valid", "valid"}], []}, :tuple_tree))
  end

  test "cannot parse element node with invalid tag" do
    {:error, %Error{} = error} = Parser.parse({:invalid, [{"valid", "valid"}], []}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse element node with invalid attribute" do
    {:error, %Error{} = error} = Parser.parse({"valid", [{:invalid, "valid"}], []}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse element node with invalid attribute value" do
    {:error, %Error{} = error} = Parser.parse({"valid", [{"valid", :invalid}], []}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse element node with invalid children" do
    {:error, %Error{} = error} = Parser.parse({"valid", [{"valid", "valid"}], nil}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # ProcessingInstruction

  test "can parse valid two element processing instruction node" do
    assert match?(%Document{}, Parser.parse({:pi, "php valid"}, :tuple_tree))
  end

  test "cannot parse two element processing instruction node with invalid data" do
    {:error, %Error{} = error} = Parser.parse({:pi, "invalid"}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "can parse valid three element processing instruction node with data" do
    assert match?(%Document{}, Parser.parse({:pi, "valid", "valid"}, :tuple_tree))
  end

  test "can parse valid three element processing instruction node with attributes" do
    assert match?(%Document{}, Parser.parse({:pi, "valid", [{"valid", "valid"}]}, :tuple_tree))
  end

  test "cannot parse three element processing instruction node with invalid target" do
    {:error, %Error{} = error} = Parser.parse({:pi, :invalid, "valid"}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  test "cannot parse three element processing instruction node invalid data" do
    {:error, %Error{} = error} = Parser.parse({:pi, "valid", :invalid}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end

  # Text

  test "can parse valid text node" do
    assert match?(%Document{}, Parser.parse({"div", [], ["valid"]}, :tuple_tree))
  end

  test "cannot parse text node with invalid text" do
    {:error, %Error{} = error} = Parser.parse({"div", [], [:invalid]}, :tuple_tree)
    assert error.type == :parser
    assert error.reason == :invalid_input
    assert error.metadata.description == "invalid tuple tree node"
  end
end
