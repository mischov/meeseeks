defmodule Meeseeks.Selector.XPath.Expr.Union do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr

  defstruct e1: nil, e2: nil

  @impl true
  def eval(expr, node, document, context) do
    v1 = Expr.eval(expr.e1, node, document, context)
    v2 = Expr.eval(expr.e2, node, document, context)

    if Expr.Helpers.nodes?(v1) and Expr.Helpers.nodes?(v2) do
      ns1 = MapSet.new(v1)
      ns2 = MapSet.new(v2)

      MapSet.union(ns1, ns2)
      |> MapSet.to_list()
      |> Enum.sort(&(comparable(&1) <= comparable(&2)))
    else
      raise "Invalid evaluated arguments to XPath union: #{inspect([v1, v2])}"
    end
  end

  defp comparable(%{id: id}), do: id
  defp comparable(x), do: x
end
