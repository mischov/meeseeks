defmodule Meeseeks.Document do
  @moduledoc """
  A `Meeseeks.Document` represents a flattened, queryable view of an HTML
  document in which:

    - The nodes (element, comment, or text) have been provided an id
    - Parent-child relationships have been made explicit

  ## Examples

  The actual contents of a document become quickly unwieldly in iex, so
  the inspect value of a document is always `#Meeseeks.Document<{...}>`
  regardless of the content. The example below ignores this fact for
  educational purposes.

  ```elixir
  tuple_tree = {"html", [],
                 [{"head", [], []},
                  {"body", [],
                   [{"h1", [{"id", "greeting"}], ["Hello, World!"]},
                    {"div", [], [
                        {"p", [], ["1"]},
                        {"p", [], ["2"]},
                        {"p", [], ["3"]}]}]}]}

  document = Meeseeks.Parser.parse(tuple_tree)
  #=> %Meeseeks.Document{
  #      id_counter: 12,
  #      roots: [1],
  #      nodes: %{
  #        1 => %Meeseeks.Document.Element{attributes: [], children: [3, 2],
  #         id: 1, namespace: nil, parent: nil, tag: "html"},
  #        2 => %Meeseeks.Document.Element{attributes: [], children: [], id: 2,
  #         namespace: nil, parent: 1, tag: "head"},
  #        3 => %Meeseeks.Document.Element{attributes: [], children: [6, 4], id: 3,
  #         namespace: nil, parent: 1, tag: "body"},
  #        4 => %Meeseeks.Document.Element{attributes: [{"id", "greeting"}],
  #         children: [5], id: 4, namespace: nil, parent: 3, tag: "h1"},
  #        5 => %Meeseeks.Document.Text{content: "Hello, World!", id: 5, parent: 4},
  #        6 => %Meeseeks.Document.Element{attributes: [], children: [7, 9, 11],
  #         id: 6, namespace: nil, parent: 3, tag: "div"},
  #        7 => %Meeseeks.Document.Element{attributes: [], children: [8], id: 7,
  #         namespace: nil, parent: 6, tag: "p"},
  #        8 => %Meeseeks.Document.Text{content: "1", id: 8, parent: 7},
  #        9 => %Meeseeks.Document.Element{attributes: [], children: [10], id: 9,
  #         namespace: nil, parent: 6, tag: "p"},
  #        10 => %Meeseeks.Document.Text{content: "2", id: 10, parent: 9},
  #        11 => %Meeseeks.Document.Element{attributes: [], children: [12], id: 11,
  #         namespace: nil, parent: 6, tag: "p"},
  #        12 => %Meeseeks.Document.Text{content: "3", id: 12, parent: 11}}}

  Meeseeks.Document.children(document, 6)
  #=> [7, 9, 11]

  Meeseeks.Document.descendants(document, 6)
  #=> [7, 8, 9, 10, 11, 12]
  ```
  """

  alias Meeseeks.Document
  alias Meeseeks.Document.{Element, Node}

  defstruct id_counter: nil, roots: [], nodes: %{}

  @type node_id :: integer
  @type node_t :: Node.t()
  @type t :: %Document{
          id_counter: node_id | nil,
          roots: [node_id],
          nodes: %{optional(node_id) => node_t}
        }

  @doc """
  Returns the HTML of the document.
  """
  def html(document) do
    document
    |> get_root_nodes()
    |> Enum.reduce("", fn root_node, acc ->
      acc <> Node.html(root_node, document)
    end)
  end

  @doc """
  Returns the `Meeseeks.TupleTree` of the document.
  """
  def tree(document) do
    document
    |> get_root_nodes()
    |> Enum.map(&Node.tree(&1, document))
  end

  # Query

  @doc """
  Checks if a node_id refers to a `Meeseeks.Document.Element` in the context
  of the document.
  """
  @spec element?(Document.t(), node_id) :: boolean
  def element?(document, node_id) do
    case get_node(document, node_id) do
      %Element{} -> true
      _ -> false
    end
  end

  @doc """
  Returns the node id of node_id's parent in the context of the document, or
  nil if node_id does not have a parent.
  """
  @spec parent(Document.t(), node_id) :: node_id | nil
  def parent(document, node_id) do
    case get_node(document, node_id) do
      %{parent: nil} -> nil
      %{parent: parent} -> parent
    end
  end

  @doc """
  Returns the node ids of node_id's ancestors in the context of the document.

  Returns the ancestors in reverse order: `[parent, grandparent, ...]`
  """
  @spec ancestors(Document.t(), node_id) :: [node_id]
  def ancestors(document, node_id) do
    case parent(document, node_id) do
      nil -> []
      parent_id -> [parent_id | ancestors(document, parent_id)]
    end
  end

  @doc """
  Returns the node ids of node_id's children in the context of the document.

  Returns *all* children, not just those that are `Meeseeks.Document.Element`s.

  Returns children in depth-first order.
  """
  @spec children(Document.t(), node_id) :: [node_id]
  def children(document, node_id) do
    case get_node(document, node_id) do
      %Document.Element{children: children} -> children
      _ -> []
    end
  end

  @doc """
  Returns the node ids of node_id's descendants in the context of the document.

  Returns *all* descendants, not just those that are `Meeseeks.Document.Element`s.

  Returns descendants in depth-first order.
  """
  @spec descendants(Document.t(), node_id) :: [node_id]
  def descendants(document, node_id) do
    case get_node(document, node_id) do
      %Element{children: children} ->
        Enum.flat_map(children, &[&1 | descendants(document, &1)])

      _ ->
        []
    end
  end

  @doc """
  Returns the node ids of node_id's siblings in the context of the document.

  Returns *all* siblings, **including node_id itself**, and not just those
  that are `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.
  """
  @spec siblings(Document.t(), node_id) :: [node_id]
  def siblings(document, node_id) do
    nd = get_node(document, node_id)

    case nd.parent do
      nil ->
        []

      parent ->
        children(document, parent)
    end
  end

  @doc """
  Returns the node ids of the siblings that come before node_id in the
  context of the document.

  Returns *all* of these siblings, not just those that are `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.
  """
  @spec previous_siblings(Document.t(), node_id) :: [node_id]
  def previous_siblings(document, node_id) do
    document
    |> siblings(node_id)
    |> Enum.take_while(fn id -> id != node_id end)
  end

  @doc """
  Returns the node ids of the siblings that come after node_id in the context
  of the document.

  Returns *all* of these siblings, not just those that are
  `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.
  """
  @spec next_siblings(Document.t(), node_id) :: [node_id]
  def next_siblings(document, node_id) do
    document
    |> siblings(node_id)
    |> Enum.drop_while(fn id -> id != node_id end)
    |> Enum.drop(1)
  end

  @doc """
  Returns all of the document's root nodes.

  Returns nodes in depth-first order.
  """
  @spec get_root_nodes(Document.t()) :: [node_t]
  def get_root_nodes(%Document{roots: roots} = document) do
    get_nodes(document, Enum.sort(roots))
  end

  @doc """
  Returns all of the document's nodes.

  Returns nodes in depth-first order.
  """
  @spec get_nodes(Document.t()) :: [node_t]
  def get_nodes(%Document{id_counter: nil}), do: []

  def get_nodes(%Document{id_counter: id_counter, nodes: nodes}) do
    for id <- 1..id_counter do
      Map.get(nodes, id, nil)
    end
  end

  @doc """
  Returns the nodes referred to by node_ids in the context of the document.

  Returns nodes in the order they are provided if node_ids are provided.
  """
  @spec get_nodes(Document.t(), [node_id]) :: [node_t]
  def get_nodes(%Document{nodes: nodes}, node_ids) do
    Enum.map(node_ids, fn node_id -> Map.get(nodes, node_id, nil) end)
  end

  @doc """
  Returns the node referred to by node_id in the context of the document.
  """
  @spec get_node(Document.t(), node_id) :: node_t
  def get_node(%Document{nodes: nodes}, node_id) do
    Map.get(nodes, node_id, nil)
  end

  # Inspect

  defimpl Inspect do
    def inspect(_document, _opts) do
      "#Meeseeks.Document<{...}>"
    end
  end
end
