defmodule Meeseeks.Document do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.{Comment, Data, Element, Text}
  alias Meeseeks.TupleTree

  defstruct(
    id_counter: nil,
    root_ids: [],
    nodes: %{},
  )

  @type node_id :: integer
  @type node_t :: Comment.t | Data.t | Element.t | Text.t
  @type t :: %Document{id_counter: node_id | nil,
                       root_ids: [node_id],
                       nodes: %{optional(node_id) => node_t}
  }

  # Build

  @spec new(TupleTree.t) :: Document.t

  def new(parsed_html) when is_list(parsed_html) do
    add_root_nodes(%Document{}, parsed_html)
  end

  def new(parsed_html) when is_tuple(parsed_html) do
    add_root_node(%Document{}, parsed_html)
  end

  defp add_root_nodes(document, roots) do
    Enum.reduce(roots, document, &(add_root_node &2, &1))
  end

  defp add_root_node(document, {tag, attributes, children}) do
    id = next_id(document.id_counter)
    [ns, tg] = split_namespace_from_tag(tag)
    node = %Element{id: id,
                    namespace: ns,
                    tag: tg,
                    attributes: attributes}
    %{document |
      id_counter: id,
      root_ids: [id | document.root_ids],
      nodes: insert_node(document.nodes, node)
    }
    |> add_child_nodes(id, children)
  end

  defp add_root_node(document, _other) do
    document
  end

  defp add_child_nodes(document, parent_id, children) do
    Enum.reduce(children, document, &(add_child_node &2, parent_id, &1))
  end

  defp add_child_node(document, parent, {tag, attributes, children}) do
    id = next_id(document.id_counter)
    [ns, tg] = split_namespace_from_tag(tag)
    node = %Element{parent: parent,
                    id: id,
                    namespace: ns,
                    tag: tg,
                    attributes: attributes}
    %{document |
      id_counter: id,
      nodes: insert_node(document.nodes, node)
    }
    |> add_child_nodes(id, children)
  end

  defp add_child_node(document, parent, {:comment, comment}) do
    id = next_id(document.id_counter)
    node = %Comment{parent: parent, id: id, content: comment}
    %{document |
      id_counter: id,
      nodes: insert_node(document.nodes, node)
    }
  end

  defp add_child_node(document, parent, text) when is_binary(text) do
    id = next_id(document.id_counter)
    parent_node = get_node(document, parent)
    if parent_node.tag == "script" or parent_node.tag == "style" do
      node = %Data{parent: parent, id: id, content: text}
      %{document |
        id_counter: id,
        nodes: insert_node(document.nodes, node)
    }
    else
      node = %Text{parent: parent, id: id, content: text}
      %{document |
        id_counter: id,
        nodes: insert_node(document.nodes, node)
    }
    end
  end

  defp add_child_node(document, _parent, _other) do
    document
  end

  defp next_id(nil), do: 1
  defp next_id(n), do: n + 1

  defp split_namespace_from_tag(maybe_namespaced_tag) do
    case :binary.split(maybe_namespaced_tag, ":", []) do
      [tg] -> [nil, tg]
      [ns, tg] -> [ns, tg]
    end
  end

  defp insert_node(nodes, %{parent: nil, id: id} = node) do
    Map.put(nodes, id, node)
  end

  defp insert_node(nodes, %{parent: parent, id: child} = node) do
    parent_node = Map.get(nodes, parent)
    children = parent_node.children
    nodes
    |> Map.put(child, node)
    |> Map.put(parent, %{parent_node | children: [child | children]})
  end

  # Query

  @spec element?(Document.t, node_id) :: boolean

  def element?(document, node_id) do
    case get_node(document, node_id) do
      %Element{} -> true
      _ -> false
    end
  end

  @spec next_siblings(Document.t, node_id) :: [node_id]

  def next_siblings(document, node_id) do
    document
    |> siblings(node_id)
    |> Enum.drop_while(fn(id) -> id != node_id end)
    |> Enum.drop(1)
  end

  @spec siblings(Document.t, node_id) :: [node_id]

  def siblings(document, node_id) do
    nd = get_node(document, node_id)
    case nd.parent do
      nil ->
        []
      parent ->
        children(document, parent)
    end
  end

  @spec children(Document.t, node_id) :: [node_id]

  def children(document, node_id) do
    case get_node(document, node_id) do
      %Document.Element{children: children} ->
        Enum.reverse(children)
      _ ->
        []
    end
  end

  @spec descendants(Document.t, node_id) :: [node_id]

  def descendants(document, node_id) do
    case get_node(document, node_id) do
      %Element{children: cs} ->
        children = Enum.reverse(cs)
        children ++ Enum.flat_map(children, &(descendants document, &1))
      _ ->
        []
    end
  end

  @spec get_nodes(Document.t) :: [node_t]

  def get_nodes(%Document{nodes: nodes}) do
    Map.values(nodes)
  end

  @spec get_nodes(Document.t, [node_id]) :: [node_t]

  def get_nodes(%Document{nodes: nodes}, node_ids) do
    Enum.map(node_ids, fn(node_id) -> Map.get(nodes, node_id, nil) end)
  end

  @spec get_node(Document.t, node_id) :: node_t

  def get_node(%Document{nodes: nodes}, node_id) do
    Map.get(nodes, node_id, nil)
  end
end

defimpl Inspect, for: Meeseeks.Document do
  @moduledoc false

  def inspect(_document, _opts) do
    "%Meeseeks.Document{...}"
  end
end
