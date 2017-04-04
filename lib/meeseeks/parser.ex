defmodule Meeseeks.Parser do
  @moduledoc false

  alias Meeseeks.{Document, TupleTree}
  alias Meeseeks.Document.{Comment, Data, Doctype, Element, Text}

  @type source :: String.t | TupleTree.t
  @type error :: {:error, String.t}

  # Parse

  @spec parse(source) :: Document.t | error

  def parse(html_string) when is_binary(html_string) do
    case Html5ever.parse(html_string) do
      {:ok, tuple_tree} -> parse_tuple_tree(tuple_tree)
      {:error, error} -> {:error, error}
    end
  end

  def parse(tuple_tree) do
    parse_tuple_tree(tuple_tree)
  end

  # Parse TupleTree

  @spec parse_tuple_tree(TupleTree.t) :: Document.t

  defp parse_tuple_tree(tuple_tree) when is_list(tuple_tree) do
    add_root_nodes(%Document{}, tuple_tree)
  end

  defp parse_tuple_tree(tuple_tree) when is_tuple(tuple_tree) do
    add_root_node(%Document{}, tuple_tree)
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
      roots: document.roots ++ [id],
      nodes: insert_node(document.nodes, node)}
    |> add_child_nodes(id, children)
  end

  defp add_root_node(document, {:comment, comment}) do
    id = next_id(document.id_counter)
    node = %Comment{id: id, content: comment}
    %{document |
      id_counter: id,
      roots: document.roots ++ [id],
      nodes: insert_node(document.nodes, node)}
  end

  defp add_root_node(document, {:doctype, type, public, system}) do
    id = next_id(document.id_counter)
    node = %Doctype{id: id, type: type, public: public, system: system}
    %{document |
      id_counter: id,
      roots: document.roots ++ [id],
      nodes: insert_node(document.nodes, node)}
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
      nodes: insert_node(document.nodes, node)}
    |> add_child_nodes(id, children)
  end

  defp add_child_node(document, parent, {:comment, comment}) do
    id = next_id(document.id_counter)
    node = %Comment{parent: parent, id: id, content: comment}
    %{document |
      id_counter: id,
      nodes: insert_node(document.nodes, node)}
  end

  defp add_child_node(document, parent, text) when is_binary(text) do
    id = next_id(document.id_counter)
    parent_node = Document.get_node(document, parent)
    if parent_node.tag == "script" or parent_node.tag == "style" do
      node = %Data{parent: parent, id: id, content: text}
      %{document |
        id_counter: id,
        nodes: insert_node(document.nodes, node)}
    else
      node = %Text{parent: parent, id: id, content: text}
      %{document |
        id_counter: id,
        nodes: insert_node(document.nodes, node)}
    end
  end

  defp add_child_node(document, _parent, _other) do
    document
  end

  defp next_id(nil), do: 1
  defp next_id(n), do: n + 1

  defp split_namespace_from_tag(maybe_namespaced_tag) do
    case :binary.split(maybe_namespaced_tag, ":", []) do
      [tg] -> ["", tg]
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
    # List append is a horrible way to build children, but the alternative
    # is walking all of the nodes at the end and reversing children, which
    # ends up being more expensive due to the iteration and map update costs.
    |> Map.put(parent, %{parent_node | children: children ++ [child]})
  end
end
