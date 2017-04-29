defmodule Meeseeks.Selector.Node do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Selector

  defstruct selectors: [], combinator: nil

  def match?(selector, node, document) do
    Enum.all?(selector.selectors, &(Selector.match? &1, node, document))
  end

  def combinator(selector), do: selector.combinator
end
