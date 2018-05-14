defmodule Meeseeks.Select do
  @moduledoc false

  alias Meeseeks.{Accumulator, Context, Document, Result, Selector}

  @return? Context.return_key()
  @matches Context.matches_key()
  @nodes Context.nodes_key()

  @type queryable :: Document.t() | Result.t()
  @type selectors :: Selector.t() | [Selector.t()]

  # All

  @spec fetch_all(queryable, selectors, Context.t()) :: {:ok, [Result.t()]} | {:error, :no_match}
  def fetch_all(queryable, selectors, context) do
    case all(queryable, selectors, context) do
      [] -> {:error, :no_match}
      results -> {:ok, results}
    end
  end

  @spec all(queryable, selectors, Context.t()) :: [Result.t()]
  def all(queryable, selectors, context) do
    context = Context.add_accumulator(context, %Accumulator.All{})
    select(queryable, selectors, context)
  end

  # One

  @spec fetch_one(queryable, selectors, Context.t()) :: {:ok, Result.t()} | {:error, :no_match}
  def fetch_one(queryable, selectors, context) do
    case one(queryable, selectors, context) do
      nil -> {:error, :no_match}
      result -> {:ok, result}
    end
  end

  @spec one(queryable, selectors, Context.t()) :: Result.t() | nil
  def one(queryable, selectors, context) do
    context = Context.add_accumulator(context, %Accumulator.One{})
    select(queryable, selectors, context)
  end

  # Select

  @spec select(queryable, selectors, Context.t()) :: any
  def select(queryable, selectors, context)

  def select(_queryable, string, _context) when is_binary(string) do
    raise "Expected selectors, received string- did you mean to wrap \"#{string}\" in the css or xpath macro?"
  end

  def select(queryable, selectors, context) do
    context =
      context
      |> Context.prepare_for_selection()
      |> Context.ensure_accumulator!()

    walk(queryable, selectors, context)
  end

  # Walk

  defp walk(%Document{} = document, selectors, context) do
    document
    |> Document.get_nodes()
    |> walk_nodes(document, selectors, context)
    |> Context.return_accumulator()
  end

  defp walk(%Result{id: id, document: document}, selectors, context) do
    ids = [id | Document.descendants(document, id)]

    document
    |> Document.get_nodes(ids)
    |> walk_nodes(document, selectors, context)
    |> Context.return_accumulator()
  end

  # Walk Nodes

  defp walk_nodes(_, _, _, %{@return? => true} = context) do
    context
  end

  defp walk_nodes([], document, _, %{@matches => matches} = context) when map_size(matches) > 0 do
    filter_and_walk(matches, document, context)
  end

  defp walk_nodes([], _, _, context) do
    context
  end

  defp walk_nodes(_, document, [], %{@matches => matches} = context) when map_size(matches) > 0 do
    filter_and_walk(matches, document, context)
  end

  defp walk_nodes(_, _, [], context) do
    context
  end

  defp walk_nodes(nodes, document, selectors, context) do
    context =
      Enum.reduce(nodes, Context.clear_matches(context), fn node, context ->
        walk_node(node, document, selectors, context)
      end)

    walk_nodes([], document, [], context)
  end

  # Walk Node

  defp walk_node(_, _, _, %{@return? => true} = context) do
    context
  end

  defp walk_node(nil, _, _, context) do
    context
  end

  defp walk_node(_, _, [], context) do
    context
  end

  defp walk_node(node, document, [selector | selectors], context) do
    context = walk_node(node, document, selector, context)

    walk_node(node, document, selectors, context)
  end

  defp walk_node(%Document.Element{} = node, document, %Selector.Element{} = selector, context) do
    case Selector.match(selector, node, document, context) do
      false -> context
      {false, context} -> context
      true -> handle_match(node, document, selector, context)
      {true, context} -> handle_match(node, document, selector, context)
    end
  end

  defp walk_node(_node, _document, %Selector.Element{} = _selector, context) do
    context
  end

  defp walk_node(node, document, selector, context) do
    case Selector.match(selector, node, document, context) do
      false -> context
      {false, context} -> context
      true -> handle_match(node, document, selector, context)
      {true, context} -> handle_match(node, document, selector, context)
    end
  end

  # Handle Match

  defp handle_match(node, document, selector, context) do
    case Selector.filters(selector) do
      # No filters, accumulate or walk directly
      nil ->
        case Selector.combinator(selector) do
          nil -> Context.add_to_accumulator(context, document, node.id)
          combinator -> walk_combinator(combinator, node, document, context)
        end

      # Filters, accumulate or store for filtering
      filters ->
        combinator = Selector.combinator(selector)

        case {combinator, filters} do
          # Add to accumulator if there is no combinator and no filters
          {nil, []} ->
            Context.add_to_accumulator(context, document, node.id)

          # Add to @matches so all matching nodes can be filtered prior to
          # continuing
          _ ->
            Context.add_to_matches(context, selector, node)
        end
    end
  end

  # Filter and Walk

  defp filter_and_walk(matching, document, context) do
    # For each set of nodes matching a selector
    Enum.reduce(matching, context, fn {selector, nodes}, context ->
      filters = Selector.filters(selector)
      nodes = Enum.reverse(nodes)
      # Filter the nodes based on the selector's filters
      {nodes, context} = filter_nodes(filters, nodes, document, context)
      walk_filtered(nodes, document, selector, context)
    end)
  end

  defp walk_filtered(nodes, document, selector, context) do
    # For each remaining node either
    Enum.reduce(nodes, context, fn node, context ->
      case Selector.combinator(selector) do
        # Add the node to the accumulator if there is no combinator
        nil ->
          Context.add_to_accumulator(context, document, node.id)

        # Or walk the combinator
        combinator ->
          walk_combinator(combinator, node, document, context)
      end
    end)
  end

  defp filter_nodes([], nodes, _, context) do
    {nodes, context}
  end

  defp filter_nodes(filters, nodes, document, context) when is_list(filters) do
    context = Map.put(context, @nodes, nodes)

    Enum.reduce(filters, {nodes, context}, fn filter, {nodes, context} ->
      filter_nodes(filter, nodes, document, context)
      |> reverse_filtered_nodes()
    end)
  end

  defp filter_nodes(filter, nodes, document, context) do
    Enum.reduce(nodes, {[], context}, fn node, {nodes, context} ->
      case Selector.match(filter, node, document, context) do
        false -> {nodes, context}
        {false, context} -> {nodes, context}
        true -> {[node | nodes], context}
        {true, context} -> {[node | nodes], context}
      end
    end)
  end

  defp reverse_filtered_nodes({nodes, context}) do
    {Enum.reverse(nodes), context}
  end

  # Walk Combinator

  defp walk_combinator(combinator, node, document, context) do
    case Selector.Combinator.next(combinator, node, document) do
      nil ->
        context

      nodes when is_list(nodes) ->
        selector = Selector.Combinator.selector(combinator)
        walk_nodes(nodes, document, selector, context)

      node ->
        selector = Selector.Combinator.selector(combinator)
        walk_nodes([node], document, selector, context)
    end
  end
end
