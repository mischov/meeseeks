defmodule Meeseeks.Selector.Node do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Selector
  alias Meeseeks.Selector.Node

  defstruct selectors: [], combinator: nil, filters: nil

  def match(%Node{selectors: []}, _node, _document, _context) do
    true
  end

  def match(selector, node, document, context) do
    Enum.all?(selector.selectors, &(Selector.match &1, node, document, context))
  end

  def combinator(selector), do: selector.combinator

  def filters(selector), do: selector.filters
end
