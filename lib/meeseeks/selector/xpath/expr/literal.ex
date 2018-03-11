defmodule Meeseeks.Selector.XPath.Expr.Literal do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  defstruct value: ""

  @impl true
  def eval(expr, _node, _document, _context) do
    expr.value
  end
end
