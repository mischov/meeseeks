defmodule Meeseeks.Selector.XPath.Expr.Negative do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr

  defstruct e: nil

  @impl true
  def eval(expr, node, document, context) do
    Expr.eval(expr.e, node, document, context)
    |> Expr.Helpers.number(document)
    |> Expr.Helpers.negate()
  end
end
