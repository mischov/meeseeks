defmodule Meeseeks.Selector.Element.PseudoClass.Not do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.{Document, Selector}
  alias Meeseeks.Selector.Element

  defstruct args: []

  def match(selector, %Document.Element{} = element, document, context) do
    case selector.args do
      [[sel]] -> !Selector.match(sel, element, document, context)

      [selectors] when is_list(selectors) ->
        !Enum.any?(selectors, &Selector.match(&1, element, document, context))

      _ -> false
    end
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  def validate(selector) do
    case selector.args do
      [selectors] when is_list(selectors) ->
        Enum.reduce_while(selectors, {:ok, selector}, &validate_selector/2)

      _ -> {:error, ":not has invalid arguments"}
    end
  end

  defp validate_selector(%Element{} = selector, ok) do
    cond do
      combinator?(selector) ->
        {:halt, {:error, ":not doesn't allow selectors containing combinators"}}

      contains_not_selector?(selector) ->
        {:halt, {:error, ":not doesn't allow selectors containing :not selectors"}}

      true -> {:cont, ok}
    end
  end

  defp combinator?(element_selector) do
    element_selector.combinator != nil
  end

  defp contains_not_selector?(element_selector) do
    Enum.any?(element_selector.selectors, &not_selector?/1)
  end

  defp not_selector?(%Element.PseudoClass.Not{}), do: true
  defp not_selector?(_), do: false
end
