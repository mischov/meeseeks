defmodule Meeseeks.Document do
  @moduledoc """
  A `Meeseeks.Document` represents a flattened, queryable view of an HTML
  document in which:

    - The nodes (element, comment, or text) have been provided an id
    - Parent-child relationships have been made explicit

  ## Examples

  The actual contents of a document become quickly unwieldly in iex, so
  the inspect value of a document is always `%Meeseeks.Document{...}`
  regardless of the content. The example below ignores this fact for
  educational purposes.

  ```elixir
  iex> tuple_tree = {"html", [],
                     [{"head", [], []},
                      {"body", [],
                       [{"h1", [{"id", "greeting"}], ["Hello, World!"]},
                        {"div", [], [
                            {"p", [], ["1"]},
                            {"p", [], ["2"]},
                            {"p", [], ["3"]}]}]}]}
  {...}

  iex> document = Meeseeks.Document(tuple_tree)
  %Meeseeks.Document{
    id_counter: 12,
    roots: [1],
    nodes: %{1 => %Meeseeks.Document.Element{attributes: [], children: [3, 2],
       id: 1, namespace: nil, parent: nil, tag: "html"},
      2 => %Meeseeks.Document.Element{attributes: [], children: [], id: 2,
       namespace: nil, parent: 1, tag: "head"},
      3 => %Meeseeks.Document.Element{attributes: [], children: [6, 4], id: 3,
       namespace: nil, parent: 1, tag: "body"},
      4 => %Meeseeks.Document.Element{attributes: [{"id", "greeting"}],
       children: [5], id: 4, namespace: nil, parent: 3, tag: "h1"},
      5 => %Meeseeks.Document.Text{content: "Hello, World!", id: 5, parent: 4},
      6 => %Meeseeks.Document.Element{attributes: [], children: [7, 9, 11],
       id: 6, namespace: nil, parent: 3, tag: "div"},
      7 => %Meeseeks.Document.Element{attributes: [], children: [8], id: 7,
       namespace: nil, parent: 6, tag: "p"},
      8 => %Meeseeks.Document.Text{content: "1", id: 8, parent: 7},
      9 => %Meeseeks.Document.Element{attributes: [], children: [10], id: 9,
       namespace: nil, parent: 6, tag: "p"},
      10 => %Meeseeks.Document.Text{content: "2", id: 10, parent: 9},
      11 => %Meeseeks.Document.Element{attributes: [], children: [12], id: 11,
       namespace: nil, parent: 6, tag: "p"},
      12 => %Meeseeks.Document.Text{content: "3", id: 12, parent: 11}}}

  iex> Meeseeks.Document.children(document, 6)
  [7, 9, 11]

  iex> Meeseeks.Document.descendants(document, 6)
  [7, 8, 9, 10, 11, 12]
  ```
  """

  alias Meeseeks.Document
  alias Meeseeks.Document.{Comment, Data, Doctype, Element, Node, Text}
  alias Meeseeks.TupleTree

  defstruct id_counter: nil, roots: [], nodes: %{}

  @type node_id :: integer
  @type node_t :: Node.t
  @type t :: %Document{id_counter: node_id | nil,
                       roots: [node_id],
                       nodes: %{optional(node_id) => node_t}}

  # Build

  @doc """
  Creates a document from a `Meeseeks.TupleTree`.

  Indexes nodes in depth-first order.

  Generally be called via `Meeseeks.Parser.parse`, not directly.
  """
  @spec new(TupleTree.t) :: Document.t

  def new(tuple_tree) when is_list(tuple_tree) do
    add_root_nodes(%Document{}, tuple_tree)
  end

  def new(tuple_tree) when is_tuple(tuple_tree) do
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
      roots: [id | document.roots],
      nodes: insert_node(document.nodes, node)}
    |> add_child_nodes(id, children)
  end

  defp add_root_node(document, {:comment, comment}) do
    id = next_id(document.id_counter)
    node = %Comment{id: id, content: comment}
    %{document |
      id_counter: id,
      roots: [id | document.roots],
      nodes: insert_node(document.nodes, node)}
  end

  defp add_root_node(document, {:doctype, type, public, system}) do
    id = next_id(document.id_counter)
    node = %Doctype{id: id, type: type, public: public, system: system}
    %{document |
      id_counter: id,
      roots: [id | document.roots],
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
    parent_node = get_node(document, parent)
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

  @doc """
  Checks if a node_id refers to a `Meeseeks.Document.Element` in the context
  of the document.
  """
  @spec element?(Document.t, node_id) :: boolean
  def element?(document, node_id) do
    case get_node(document, node_id) do
      %Element{} -> true
      _ -> false
    end
  end

  @doc """
  Returns the node ids of node_id's children in the context of the document.

  Returns *all* children, not just those that are `Meeseeks.Document.Element`s.

  Returns children in depth-first order.
  """
  @spec children(Document.t, node_id) :: [node_id]
  def children(document, node_id) do
    case get_node(document, node_id) do
      %Document.Element{children: children} ->
        Enum.reverse(children)
      _ -> []
    end
  end

  @doc """
  Returns the node ids of node_id's descendants in the context of the document.

  Returns *all* descendants, not just those that are `Meeseeks.Document.Element`s.

  Returns descendants in depth-first order.
  """
  @spec descendants(Document.t, node_id) :: [node_id]
  def descendants(document, node_id) do
    case get_node(document, node_id) do
      %Element{children: cs} ->
        children = Enum.reverse(cs)
        Enum.flat_map(children, &[&1 | descendants(document, &1)])
      _ -> []
    end
  end

  @doc """
  Returns the node ids of node_id's siblings in the context of the document.

  Returns *all* siblings, **including node_id itself**, and not just those
  that are `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.
  """
  @spec siblings(Document.t, node_id) :: [node_id]
  def siblings(document, node_id) do
    nd = get_node(document, node_id)
    case nd.parent do
      nil -> []
      parent ->
        children(document, parent)
    end
  end

  @doc """
  Returns the node ids of the siblings that come after node_id in the context
  of the document.

  Returns *all* of these siblings, not just those that are `Meeseeks.Document.Element`s

  Returns siblings in depth-first order.
  """
  @spec next_siblings(Document.t, node_id) :: [node_id]
  def next_siblings(document, node_id) do
    document
    |> siblings(node_id)
    |> Enum.drop_while(fn(id) -> id != node_id end)
    |> Enum.drop(1)
  end

  @doc """
  Returns all of the document's nodes.

  Returns nodes in depth-first order.
  """
  @spec get_nodes(Document.t) :: [node_t]
  def get_nodes(%Document{id_counter: id_counter, nodes: nodes}) do
    for id <- 1..id_counter do
      Map.get(nodes, id, nil)
    end
  end

  @doc """
  Returns the nodes referred to by node_ids in the context of the document.

  Returns nodes in the order they are provided if node_ids are provided.
  """
  @spec get_nodes(Document.t, [node_id]) :: [node_t]
  def get_nodes(%Document{nodes: nodes}, node_ids) do
    Enum.map(node_ids, fn(node_id) -> Map.get(nodes, node_id, nil) end)
  end

  @doc """
  Returns the node referred to by node_id in the context of the document.
  """
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
