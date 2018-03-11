defmodule Meeseeks.Selector.XPath.Expr.Boolean do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr

  defstruct op: nil, e1: nil, e2: nil

  @impl true
  def eval(%Expr.Boolean{op: :or} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.boolean(document)

    if v1 do
      true
    else
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.boolean(document)
    end
  end

  def eval(%Expr.Boolean{op: :and} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.boolean(document)

    if v1 do
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.boolean(document)
    else
      false
    end
  end
end
