defmodule Meeseeks.Selector.XPath.Expr.Arithmetic do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr

  defstruct op: nil, e1: nil, e2: nil

  @impl true
  def eval(%Expr.Arithmetic{op: :+} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.number(document)

    v2 =
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.number(document)

    Expr.Helpers.add(v1, v2)
  end

  def eval(%Expr.Arithmetic{op: :-} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.number(document)

    v2 =
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.number(document)

    Expr.Helpers.sub(v1, v2)
  end

  def eval(%Expr.Arithmetic{op: :*} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.number(document)

    v2 =
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.number(document)

    Expr.Helpers.mult(v1, v2)
  end

  def eval(%Expr.Arithmetic{op: :div} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.number(document)

    v2 =
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.number(document)

    Expr.Helpers.divd(v1, v2)
  end

  def eval(%Expr.Arithmetic{op: :mod} = expr, node, document, context) do
    v1 =
      Expr.eval(expr.e1, node, document, context)
      |> Expr.Helpers.number(document)

    v2 =
      Expr.eval(expr.e2, node, document, context)
      |> Expr.Helpers.number(document)

    Expr.Helpers.mod(v1, v2)
  end
end
