defmodule Meeseeks.Selector.Root do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Selector

  defstruct selectors: [], combinator: nil

  def match?(selector, %{parent: nil} = node, document) do
    Enum.all?(selector.selectors, &(Selector.match? &1, node, document))
  end

  def match?(_selector, _node, _document) do
    false
  end

  def combinator(selector), do: selector.combinator
end
