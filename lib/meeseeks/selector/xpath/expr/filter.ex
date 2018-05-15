defmodule Meeseeks.Selector.XPath.Expr.Filter do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.{Context, Error}
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
      raise Error.new(:xpath_expression, :invalid_evaluated_arguments, %{
              evaluated_arguments: [v],
              expression: expr
            })
    end
  end
end
