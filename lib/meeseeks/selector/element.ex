defmodule Meeseeks.Selector.Element do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.{Document, Selector}
  alias Meeseeks.Selector.Element

  defstruct selectors: [], combinator: nil, filters: nil

  @impl true
  def match(%Element{selectors: []}, %Document.Element{}, _document, _context) do
    true
  end

  def match(selector, %Document.Element{} = element, document, context) do
    Enum.all?(selector.selectors, &Selector.match(&1, element, document, context))
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def combinator(selector), do: selector.combinator

  @impl true
  def filters(selector), do: selector.filters
end
