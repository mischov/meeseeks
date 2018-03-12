defmodule Meeseeks.Selector.Root do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Selector
  alias Meeseeks.Selector.Root

  defstruct selectors: [], combinator: nil, filters: nil

  @impl true
  def match(%Root{selectors: []}, %{parent: nil}, _document, _context) do
    true
  end

  def match(selector, %{parent: nil} = node, document, context) do
    Enum.all?(selector.selectors, &Selector.match(&1, node, document, context))
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def combinator(selector), do: selector.combinator

  @impl true
  def filters(selector), do: selector.filters
end
