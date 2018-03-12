defmodule Meeseeks.Selector.Node do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Selector
  alias Meeseeks.Selector.Node

  defstruct selectors: [], combinator: nil, filters: nil

  @impl true
  def match(%Node{selectors: []}, _node, _document, _context) do
    true
  end

  def match(selector, node, document, context) do
    Enum.all?(selector.selectors, &Selector.match(&1, node, document, context))
  end

  @impl true
  def combinator(selector), do: selector.combinator

  @impl true
  def filters(selector), do: selector.filters
end
