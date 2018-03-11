defmodule Meeseeks.Selector.XPath.Expr.Number do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  defstruct value: 0

  @impl true
  def eval(expr, _node, _document, _context) do
    expr.value
  end
end
