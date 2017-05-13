defmodule Meeseeks.Selector.Combinator.Self do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  defstruct selector: nil

  def next(_combinator, node, _document) do
    node
  end
end
