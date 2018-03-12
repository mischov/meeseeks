defmodule Meeseeks.Selector.XPath.Expr.Filter do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Context
  alias Meeseeks.Selector.XPath.Expr

  @nodes Context.nodes_key()

  defstruct e: nil, predicate: nil

  @impl true
  def eval(expr, node, document, context) do
    v = Expr.eval(expr.e, node, document, context)

    if Expr.Helpers.nodes?(v) do
      context = Map.put(context, @nodes, v)

      Enum.filter(v, &Expr.eval(expr.predicate, &1, document, context))
    else
      raise "Invalid evaluated argument to XPath filter: #{inspect(v)}"
    end
  end
end
