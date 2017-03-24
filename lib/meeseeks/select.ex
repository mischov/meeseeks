defmodule Meeseeks.Select do
  @moduledoc false

  alias Meeseeks.{Accumulator, Document, Result, Selector}

  @type queryable :: Document.t | Result.t
  @type selectors :: Selector.t | [Selector.t]

  # All

  @spec all(queryable, selectors) :: [Result.t]

  def all(queryable, selectors) do
    walk(queryable, selectors, %Accumulator.All{})
  end

  # One

  @spec one(queryable, selectors) :: Result.t

  def one(queryable, selectors) do
    walk(queryable, selectors, %Accumulator.One{})
  end

  # Walk

  defp walk(%Document{} = document, selectors, acc) do
    document
    |> Document.get_nodes()
    |> walk_nodes(document, selectors, acc)
    |> Accumulator.return
  end

  defp walk(%Result{id: id, document: document}, selectors, acc) do
    ids = [id | Document.descendants(document, id)]
    document
    |> Document.get_nodes(ids)
    |> walk_nodes(document, selectors, acc)
    |> Accumulator.return
  end

  # Walk Nodes

  defp walk_nodes(_, _, _, %Accumulator.One{value: v} = acc) when v != nil do
    acc
  end

  defp walk_nodes([], _, _, acc) do
    acc
  end

  defp walk_nodes(_, _, [], acc) do
    acc
  end

  defp walk_nodes(nodes, document, selectors, acc) do
    Enum.reduce(
      nodes,
      acc,
      fn(nd, acc) -> walk_node(nd, document, selectors, acc) end
    )
  end

  # Walk Node

  defp walk_node(_, _, _, %Accumulator.One{value: v} = acc) when v != nil do
    acc
  end

  defp walk_node(nil, _, _, acc) do
    acc
  end

  defp walk_node(_, _, [], acc) do
    acc
  end

  defp walk_node(node, document, [selector|selectors], acc) do
    acc = walk_node(node, document, selector, acc)
    walk_node(node, document, selectors, acc)
  end

  defp walk_node(%Document.Element{} = node, document, %Selector.Element{} = selector, acc) do
    if Selector.match?(selector, node, document) do
      case Selector.combinator(selector) do
        nil -> Accumulator.add(acc, document, node.id)
        combinator -> walk_combinator(combinator, node, document, acc)
      end
    else
      acc
    end
  end

  defp walk_node(_node, _document, %Selector.Element{} = _selector, acc) do
    acc
  end

  defp walk_node(node, document, selector, acc) do
    if Selector.match?(selector, node, document) do
      case Selector.combinator(selector) do
        nil -> Accumulator.add(acc, document, node.id)
        combinator -> walk_combinator(combinator, node, document, acc)
      end
    else
      acc
    end
  end

  # Walk Combinator

  defp walk_combinator(combinator, node, document, acc) do
    case Selector.Combinator.next(combinator, node, document) do
      nil -> acc

      nodes when is_list(nodes) ->
        selector = Selector.Combinator.selector(combinator)
        walk_nodes(nodes, document, selector, acc)

      node ->
        selector = Selector.Combinator.selector(combinator)
        walk_node(node, document, selector, acc)
    end
  end
end
