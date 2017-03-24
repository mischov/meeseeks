defmodule Meeseeks.Selector.Element do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.{Document, Selector}

  defstruct selectors: [], combinator: nil

  def match?(selector, %Document.Element{} = element, document) do
    Enum.all?(selector.selectors, &(Selector.match? &1, element, document))
  end

  def match?(_selector, _node, _document) do
    false
  end

  def combinator(selector), do: selector.combinator
end
