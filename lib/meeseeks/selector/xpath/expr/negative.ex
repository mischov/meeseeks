defmodule Meeseeks.Selector.XPath.Expr.Negative do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Selector.XPath.Expr

  defstruct e: nil

  def eval(expr, node, document, context) do
    Expr.eval(expr.e, node, document, context)
    |> Expr.Helpers.number(document)
    |> Expr.Helpers.negate()
  end
end
