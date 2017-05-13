defmodule Meeseeks.Selector.XPath.Expr.Comparative do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Selector.XPath.Expr

  defstruct op: nil, e1: nil, e2: nil

  def eval(%Expr.Comparative{op: :=} = expr, node, document, context) do
    v1 = Expr.eval(expr.e1, node, document, context)
    v2 = Expr.eval(expr.e2, node, document, context)
    compare(
      expr.op,
      Expr.Helpers.eq_fmt(v1, v2, document),
      Expr.Helpers.eq_fmt(v2, v1, document)
    )
  end

  def eval(%Expr.Comparative{op: :!=} = expr, node, document, context) do
    v1 = Expr.eval(expr.e1, node, document, context)
    v2 = Expr.eval(expr.e2, node, document, context)
    compare(
      expr.op,
      Expr.Helpers.eq_fmt(v1, v2, document),
      Expr.Helpers.eq_fmt(v2, v1, document)
    )
  end

  def eval(expr, node, document, context) do
    v1 = Expr.eval(expr.e1, node, document, context)
    v2 = Expr.eval(expr.e2, node, document, context)
    compare(
      expr.op,
      Expr.Helpers.cmp_fmt(v1, v2, document),
      Expr.Helpers.cmp_fmt(v2, v1, document)
    )
  end

  def compare(op, x, y) when is_list(x) and is_list(y) do
    Enum.any?(x, fn(xv) ->
      Enum.any?(y, fn(yv) ->
        Expr.Helpers.compare(op, xv, yv)
      end)
    end)
  end
  def compare(op, x, y) when is_list(x) do
    Enum.any?(x, fn(xv) -> Expr.Helpers.compare(op, xv, y) end)
  end
  def compare(op, x, y) when is_list(y) do
    Enum.any?(y, fn(yv) -> Expr.Helpers.compare(op, x, yv) end)
  end
  def compare(op, x, y) do
    Expr.Helpers.compare(op, x, y)
  end
end
