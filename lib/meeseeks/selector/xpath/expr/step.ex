defmodule Meeseeks.Selector.XPath.Expr.Step do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Selector
  alias Meeseeks.Selector.XPath.Expr

  defstruct combinator: nil, predicates: []

  def eval(expr, node, document, context) do
    case Selector.Combinator.next(expr.combinator, node, document) do
      nil -> []
      nodes when is_list(nodes) ->
        filter_nodes(nodes, expr.predicates, document, context)
      node -> filter_nodes([node], expr.predicates, document, context)
    end
  end

  defp filter_nodes(nodes, predicates, document, context) do
    Enum.filter(nodes, &filter_node(&1, predicates, document, context))
  end

  defp filter_node(node, predicates, document, context) do
    Enum.all?(predicates, &Expr.eval(&1, node, document, context))
  end
end
