defmodule Meeseeks.Selector.XPath.Expr.Path do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr
  alias Meeseeks.Selector.XPath.Expr.Path

  defstruct type: nil, steps: []

  def eval(%Path{type: :abs} = expr, _node, document, context) do
    root_nodes = Document.get_nodes(document, document.roots)
    next_step(expr.steps, root_nodes, document, context)
  end

  def eval(%Path{type: :rel} = expr, node, document, context) do
    next_step(expr.steps, [node], document, context)
  end

  defp next_step(_steps, [], _document, _context) do
    []
  end

  defp next_step([step|steps], nodes, document, context) when is_list(nodes) do
    case steps do
      [] ->
        Enum.reduce(nodes, [], fn(node, nodes) ->
          nodes ++ Expr.eval(step, node, document, context)
        end)
      steps ->
        Enum.reduce(nodes, [], fn(node, nodes) ->
          v = Expr.eval(step, node, document, context)
          nodes ++ next_step(steps, v, document, context)
        end)
    end
  end

  defp next_step([step|steps], node, document, context) do
    case steps do
      [] -> Expr.eval(step, node, document, context)
      steps ->
        v = Expr.eval(step, node, document, context)
        next_step(steps, v, document, context)
    end
  end
end
