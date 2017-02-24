defmodule Meeseeks.Select do
  @moduledoc false

  alias Meeseeks.{Accumulator, Document, Result, Selector}

  @type queryable :: Document.t | Result.t
  @type selectors :: String.t | [Selector.t]

  # All

  @spec all(queryable, selectors) :: [Result.t]

  def all(queryable, selector_string) when is_binary(selector_string) do
    selectors = Selector.parse_selectors(selector_string)
    walk(queryable, selectors, %Accumulator.All{})
  end

  def all(queryable, selectors) when is_list(selectors) do
    walk(queryable, selectors, %Accumulator.All{})
  end

  # One

  @spec one(queryable, selectors) :: Result.t

  def one(queryable, selector_string) when is_binary(selector_string) do
    selectors = Selector.parse_selectors(selector_string)
    walk(queryable, selectors, %Accumulator.One{})
  end

  def one(queryable, selectors) when is_list(selectors) do
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

  defp walk_nodes(_, _, [], acc) do
    acc
  end

  defp walk_nodes([], _, _, acc) do
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

  defp walk_node(_, _, [], acc) do
    acc
  end

  defp walk_node(nil, _, _, acc) do
    acc
  end

  defp walk_node(%Document.Text{}, _, _, acc) do
    acc
  end

  defp walk_node(%Document.Comment{}, _, _, acc) do
    acc
  end

  defp walk_node(element, document, [selector|selectors], acc) do
    acc1 = walk_node(element, document, selector, acc)
    walk_node(element, document, selectors, acc1)
  end

  defp walk_node(element, document, selector, acc) do
    if Selector.Element.match?(document, element, selector) do
      case selector.combinator do
        nil -> Accumulator.add(acc, document, element.id)
        combinator -> walk_combinator(combinator, element, document, acc)
      end
    else
      acc
    end
  end

  # Walk Combinator

  defp walk_combinator(_, %Document.Element{children: []}, _, acc) do
    acc
  end

  defp walk_combinator(combinator, element, document, acc) do
    selector = combinator.selector

    case combinator.match do
      :descendant ->
        descendants = Document.descendants(document, element.id)
        descendant_nodes = Document.get_nodes(document, descendants)
        walk_nodes(descendant_nodes, document, [selector], acc)

      :child ->
        children = Document.children(document, element.id)
        child_nodes = Document.get_nodes(document, children)
        walk_nodes(child_nodes, document, [selector], acc)

      :next_sibling ->
        next_sibling = Document.next_sibling(document, element.id)
        next_sibling_node = Document.get_node(document, next_sibling)
        walk_node(next_sibling_node, document, [selector], acc)

      :next_siblings ->
        next_siblings = Document.next_siblings(document, element.id)
        next_sibling_nodes = Document.get_nodes(document, next_siblings)
        walk_nodes(next_sibling_nodes, document, [selector], acc)
    end
  end
end
