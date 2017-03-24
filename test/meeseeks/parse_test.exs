defmodule Meeseeks.ParseTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Parser

  test "comment can exist at root" do
    document = Parser.parse("<!-- Hi --><html></html>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &comment_node?/1)
  end

  test "comment can exist as child" do
    document = Parser.parse("<div><!-- Hi --></div>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &comment_node?/1)
  end

  test "data can exist as child" do
    document = Parser.parse("<script>Hi</script>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &data_node?/1)
  end

  test "doctype can exist at root" do
    document = Parser.parse("<!DOCTYPE html><html></html>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &doctype_node?/1)
  end

  test "doctype can't exist elsewhere" do
    document = Parser.parse("<div><!DOCTYPE html></div>")
    nodes = document.nodes |> Map.values()
    refute Enum.any?(nodes, &doctype_node?/1)
  end

  test "element can exist at root" do
    document = Parser.parse("<html></html>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &element_node?/1)
  end

  test "element can exist as child" do
    document = Parser.parse("<div><p>Hi</p></div>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &element_node?/1)
  end

  test "text can exist as child" do
    document = Parser.parse("<p>Hi</p>")
    nodes = document.nodes |> Map.values()
    assert Enum.any?(nodes, &text_node?/1)
  end

  defp comment_node?(%Document.Comment{}), do: true
  defp comment_node?(_), do: false

  defp data_node?(%Document.Data{}), do: true
  defp data_node?(_), do: false

  defp doctype_node?(%Document.Doctype{}), do: true
  defp doctype_node?(_), do: false

  defp element_node?(%Document.Element{}), do: true
  defp element_node?(_), do: false

  defp text_node?(%Document.Text{}), do: true
  defp text_node?(_), do: false
end
