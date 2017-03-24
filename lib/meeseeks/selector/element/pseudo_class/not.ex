defmodule Meeseeks.Selector.Element.PseudoClass.Not do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.{Document, Selector}
  alias Meeseeks.Selector.Element

  defstruct args: []

  def match?(selector, %Document.Element{} = element, document) do
    case selector.args do
      [%Element{} = sel] -> !Selector.match?(sel, element, document)
      _ -> false
    end
  end

  def match?(_selector, _node, _document) do
    false
  end

  def validate(selector) do
    case selector.args do
      [%Element{} = sel] ->
        cond do
           combinator?(sel) ->
            {:error, ":not doesn't allow selectors containing combinators"}

          contains_not_selector?(sel) ->
            {:error, ":not doesn't allow selectors containing :not selectors"}
          true -> {:ok, selector}
        end

      _ -> {:error, ":not has invalid arguments"}
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
