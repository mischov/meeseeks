defmodule Meeseeks.Selector.Root do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Selector
  alias Meeseeks.Selector.Root

  defstruct selectors: [], combinator: nil, filters: nil

  def match(%Root{selectors: []}, %{parent: nil}, _document, _context) do
    true
  end

  def match(selector, %{parent: nil} = node, document, context) do
    Enum.all?(selector.selectors, &(Selector.match &1, node, document, context))
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  def combinator(selector), do: selector.combinator

  def filters(selector), do: selector.filters
end
