defmodule Meeseeks.CSS_Test do
  use ExUnit.Case
  doctest Meeseeks.CSS

  import Meeseeks.CSS

  @expected %Meeseeks.Selector.Element{
    combinator: nil,
    filters: nil,
    selectors: [%Meeseeks.Selector.Element.Tag{value: "*"}]
  }

  test "can compile string literal" do
    assert css("*") == @expected
  end

  test "can compile interpolated with #" do
    value = "*"
    assert css("#{value}") == @expected
  end

  test "can compile interpolated with <>" do
    assert css("" <> "*") == @expected
  end

  test "can compile from var" do
    selector_string = "*"
    assert css(selector_string) == @expected
  end
end
