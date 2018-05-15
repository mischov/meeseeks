defmodule Meeseeks.Selector.Element.PseudoClass.NthLastOfType do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.{Document, Error}
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  @impl true
  def match(_selector, %Document.Element{parent: nil}, _document, _context) do
    false
  end

  def match(selector, %Document.Element{} = element, document, _context) do
    case selector.args do
      ["even"] ->
        index = Helpers.backwards_index_of_type(element, document)

        Helpers.nth?(index, 2, 0)

      ["odd"] ->
        index = Helpers.backwards_index_of_type(element, document)

        Helpers.nth?(index, 2, 1)

      [n] when is_integer(n) ->
        index = Helpers.backwards_index_of_type(element, document)

        Helpers.nth?(index, 0, n)

      [a, b] when is_integer(a) and is_integer(b) ->
        index = Helpers.backwards_index_of_type(element, document)

        Helpers.nth?(index, a, b)

      _ ->
        false
    end
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def validate(selector) do
    case selector.args do
      ["even"] ->
        {:ok, selector}

      ["odd"] ->
        {:ok, selector}

      [n] when is_integer(n) ->
        {:ok, selector}

      [a, b] when is_integer(a) and is_integer(b) ->
        {:ok, selector}

      _ ->
        {:error,
         Error.new(:css_selector, :invalid, %{
           description: ":nth-last-of-type has invalid arguments",
           selector: selector
         })}
    end
  end
end
