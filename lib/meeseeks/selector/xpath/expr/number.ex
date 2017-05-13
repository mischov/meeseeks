defmodule Meeseeks.Selector.XPath.Expr.Number do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  defstruct value: 0

  def eval(expr, _node, _document, _context) do
    expr.value
  end
end
