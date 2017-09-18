defmodule MeeseeksTest do
  use ExUnit.Case
  doctest Meeseeks

  test "extractors propagate nil input" do
    assert Meeseeks.attr(nil, "attr") == nil
    assert Meeseeks.attrs(nil) == nil
    assert Meeseeks.data(nil) == nil
    assert Meeseeks.dataset(nil) == nil
    assert Meeseeks.html(nil) == nil
    assert Meeseeks.own_text(nil) == nil
    assert Meeseeks.tag(nil) == nil
    assert Meeseeks.text(nil) == nil
    assert Meeseeks.tree(nil) == nil
  end
end
