defmodule Meeseeks.Selector.Element.PseudoClass.NthLastChild do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  def match?(_selector, %Document.Element{parent: nil}, _document) do
    false
  end

  def match?(selector, %Document.Element{} = element, document) do
    case selector.args do
      ["even"] ->
        index = Helpers.backwards_index(element, document)
        Helpers.nth?(index, 2, 0)

      ["odd"] ->
        index = Helpers.backwards_index(element, document)
        Helpers.nth?(index, 2, 1)

      [n] when is_integer(n) ->
        index = Helpers.backwards_index(element, document)
        Helpers.nth?(index, 0, n)

      [a, b] when is_integer(a) and is_integer(b) ->
        index = Helpers.backwards_index(element, document)
        Helpers.nth?(index, a, b)

      _ -> false
    end
  end

  def match?(_selector, _node, _document) do
    false
  end

  def validate(selector) do
    case selector.args do
      ["even"] -> {:ok, selector}
      ["odd"] -> {:ok, selector}
      [n] when is_integer(n) -> {:ok, selector}
      [a, b] when is_integer(a) and is_integer(b) -> {:ok, selector}
      _ -> {:error, ":nth-last-child has invalid arguments"}
    end
  end
end
