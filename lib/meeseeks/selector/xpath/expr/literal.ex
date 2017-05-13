defmodule Meeseeks.Selector.XPath.Expr.Literal do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  defstruct value: ""

  def eval(expr, _node, _document, _context) do
    expr.value
  end
end
