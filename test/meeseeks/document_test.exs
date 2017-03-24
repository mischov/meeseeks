defmodule Meeseeks.DocumentTest do
  use ExUnit.Case

  alias Meeseeks.Document

  @document Document.new(
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

  test "body > div children" do
    assert Document.children(@document, 4) == [5, 6, 7, 10]
  end

  test "descendants" do
    assert Document.descendants(@document, 4) == [5, 6, 7, 8, 9, 10]
  end

  test "siblings" do
    assert Document.siblings(@document, 6) == [5, 6, 7, 10]
  end

  test "next_siblings" do
    assert Document.next_siblings(@document, 6) == [7, 10]
  end
end
