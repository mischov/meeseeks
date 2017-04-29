defmodule Meeseeks.DocumentTest do
  use ExUnit.Case

  alias Meeseeks.Document

  @document Meeseeks.Parser.parse(
    {"html", [], [
        {"head", [], []},
        {"body", [], [
            {"div", [], [
                {"p", [], []},
                {"p", [], []},
                {"div", [], [
                    {"p", [], []},
                    {"p", [], []}]},
                {"p", [], []}]}]}]})

  test "html node is element?" do
    assert Document.element?(@document, 1)
  end

  test "parent" do
    assert Document.parent(@document, 7) == 4
  end

  test "no parent" do
    assert Document.parent(@document, 1) == nil
  end

  test "ancestors" do
    assert Document.ancestors(@document, 7) == [4, 3, 1]
  end

  test "no ancestors" do
    assert Document.ancestors(@document, 1) == []
  end

  test "children" do
    assert Document.children(@document, 4) == [5, 6, 7, 10]
  end

  test "descendants" do
    assert Document.descendants(@document, 4) == [5, 6, 7, 8, 9, 10]
  end

  test "siblings" do
    assert Document.siblings(@document, 6) == [5, 6, 7, 10]
  end

  test "previous_siblings" do
    assert Document.previous_siblings(@document, 7) == [5, 6]
  end

  test "next_siblings" do
    assert Document.next_siblings(@document, 6) == [7, 10]
  end
end
