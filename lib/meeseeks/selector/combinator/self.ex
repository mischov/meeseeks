defmodule Meeseeks.Selector.Combinator.Self do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  defstruct selector: nil

  @impl true
  def next(_combinator, node, _document) do
    node
  end
end
