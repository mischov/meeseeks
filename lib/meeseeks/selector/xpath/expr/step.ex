defmodule Meeseeks.Selector.XPath.Expr.Step do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.{Context, Selector}
  alias Meeseeks.Selector.XPath.Expr

  defstruct combinator: nil, predicates: []

  @nodes Context.nodes_key()

  @impl true
  def eval(expr, node, document, context) do
    case Selector.Combinator.next(expr.combinator, node, document) do
      nil ->
        []

      nodes when is_list(nodes) ->
        filter_nodes_by_predicates(nodes, expr.predicates, document, context)

      node ->
        filter_nodes_by_predicates([node], expr.predicates, document, context)
    end
  end

  defp filter_nodes_by_predicates(nodes, predicates, document, context) do
    Enum.reduce(predicates, nodes, &filter_nodes_by_predicate(&2, &1, document, context))
  end

  defp filter_nodes_by_predicate(nodes, predicate, document, context) do
    context = Map.put(context, @nodes, nodes)
    Enum.filter(nodes, &Expr.eval(predicate, &1, document, context))
  end
end
