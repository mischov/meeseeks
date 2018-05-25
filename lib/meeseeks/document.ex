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

  alias Meeseeks.{Document, Error}
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
  def html(%Document{} = document) do
    document
    |> get_root_nodes()
    |> Enum.reduce("", fn root_node, acc ->
      acc <> Node.html(root_node, document)
    end)
  end

  @doc """
  Returns the `Meeseeks.TupleTree` of the document.
  """
  def tree(%Document{} = document) do
    document
    |> get_root_nodes()
    |> Enum.map(&Node.tree(&1, document))
  end

  # Query

  @doc """
  Checks if a node_id refers to a `Meeseeks.Document.Element` in the context
  of the document.

  Raises if node_id does not exist in the document.
  """
  @spec element?(Document.t(), node_id) :: boolean | no_return
  def element?(%Document{} = document, node_id) do
    case fetch_node(document, node_id) do
      {:ok, %Element{}} -> true
      {:ok, _} -> false
      {:error, %Error{} = error} -> raise error
    end
  end

  @doc """
  Returns the node id of node_id's parent in the context of the document, or
  nil if node_id does not have a parent.

  Raises if node_id does not exist in the document.
  """
  @spec parent(Document.t(), node_id) :: node_id | nil | no_return
  def parent(%Document{} = document, node_id) do
    case fetch_node(document, node_id) do
      {:ok, %{parent: nil}} -> nil
      {:ok, %{parent: parent}} -> parent
      {:error, %Error{} = error} -> raise error
    end
  end

  @doc """
  Returns the node ids of node_id's ancestors in the context of the document.

  Returns the ancestors in reverse order: `[parent, grandparent, ...]`

  Raises if node_id does not exist in the document.
  """
  @spec ancestors(Document.t(), node_id) :: [node_id] | no_return
  def ancestors(%Document{} = document, node_id) do
    case parent(document, node_id) do
      nil -> []
      parent_id -> [parent_id | ancestors(document, parent_id)]
    end
  end

  @doc """
  Returns the node ids of node_id's children in the context of the document.

  Returns *all* children, not just those that are `Meeseeks.Document.Element`s.

  Returns children in depth-first order.

  Raises if node_id does not exist in the document.
  """
  @spec children(Document.t(), node_id) :: [node_id] | no_return
  def children(%Document{} = document, node_id) do
    case fetch_node(document, node_id) do
      {:ok, %Document.Element{children: children}} -> children
      {:ok, _} -> []
      {:error, %Error{} = error} -> raise error
    end
  end

  @doc """
  Returns the node ids of node_id's descendants in the context of the document.

  Returns *all* descendants, not just those that are `Meeseeks.Document.Element`s.

  Returns descendants in depth-first order.

  Raises if node_id does not exist in the document.
  """
  @spec descendants(Document.t(), node_id) :: [node_id] | no_return
  def descendants(%Document{} = document, node_id) do
    case fetch_node(document, node_id) do
      {:ok, %Element{children: children}} ->
        Enum.flat_map(children, &[&1 | descendants(document, &1)])

      {:ok, _} ->
        []

      {:error, %Error{} = error} ->
        raise error
    end
  end

  @doc """
  Returns the node ids of node_id's siblings in the context of the document.

  Returns *all* siblings, **including node_id itself**, and not just those
  that are `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.

  Raises if node_id does not exist in the document.
  """
  @spec siblings(Document.t(), node_id) :: [node_id] | no_return
  def siblings(%Document{} = document, node_id) do
    with {:ok, node} <- fetch_node(document, node_id) do
      case node.parent do
        nil -> get_root_ids(document)
        parent -> children(document, parent)
      end
    else
      {:error, %Error{} = error} -> raise error
    end
  end

  @doc """
  Returns the node ids of the siblings that come before node_id in the
  context of the document.

  Returns *all* of these siblings, not just those that are `Meeseeks.Document.Element`s.

  Returns siblings in depth-first order.

  Raises if node_id does not exist in the document.
  """
  @spec previous_siblings(Document.t(), node_id) :: [node_id] | no_return
  def previous_siblings(%Document{} = document, node_id) do
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

  Raises if node_id does not exist in the document.
  """
  @spec next_siblings(Document.t(), node_id) :: [node_id] | no_return
  def next_siblings(%Document{} = document, node_id) do
    document
    |> siblings(node_id)
    |> Enum.drop_while(fn id -> id != node_id end)
    |> Enum.drop(1)
  end

  @doc """
  Returns all of the document's root ids.

  Returns root ids in depth-first order.
  """
  @spec get_root_ids(Document.t()) :: [node_id]
  def get_root_ids(%Document{roots: roots}) do
    Enum.sort(roots)
  end

  @doc """
  Returns all of the document's root nodes.

  Returns nodes in depth-first order.
  """
  @spec get_root_nodes(Document.t()) :: [node_t]
  def get_root_nodes(%Document{} = document) do
    root_ids = get_root_ids(document)
    get_nodes(document, root_ids)
  end

  @doc """
  Returns all of the document's node ids.

  Returns node ids in depth-first order.
  """
  @spec get_node_ids(Document.t()) :: [node_id]
  def get_node_ids(%Document{nodes: nodes}) do
    nodes
    |> Map.keys()
    |> Enum.sort()
  end

  @doc """
  Returns all of the document's nodes.

  Returns nodes in depth-first order.
  """
  @spec get_nodes(Document.t()) :: [node_t]
  def get_nodes(%Document{nodes: nodes} = document) do
    for id <- get_node_ids(document) do
      Map.get(nodes, id, nil)
    end
  end

  @doc """
  Returns a list of nodes referred to by node_ids in the context of the document.

  Returns nodes in the same order as node_ids.

  Raises if any id in node_ids does not exist in the document.
  """
  @spec get_nodes(Document.t(), [node_id]) :: [node_t] | no_return
  def get_nodes(document, node_ids) do
    Enum.map(node_ids, fn node_id ->
      case fetch_node(document, node_id) do
        {:ok, node} -> node
        {:error, error} -> raise error
      end
    end)
  end

  @doc """
  Returns a tuple of {:ok, node}, where node is the node referred to by node_id in the context of the document, or :error.
  """
  @spec fetch_node(Document.t(), node_id) :: {:ok, node_t} | {:error, Error.t()}
  def fetch_node(%Document{nodes: nodes} = document, node_id) do
    case Map.fetch(nodes, node_id) do
      {:ok, _} = ok ->
        ok

      :error ->
        {:error,
         Error.new(:document, :unknown_node, %{
           description: "No node with the provided id exists in the document",
           document: document,
           node_id: node_id
         })}
    end
  end

  @doc """
  Returns the node referred to by node_id in the context of the document, or nil.
  """
  @spec get_node(Document.t(), node_id) :: node_t
  def get_node(%Document{nodes: nodes}, node_id) do
    Map.get(nodes, node_id, nil)
  end

  @doc """
  Deletes the node referenced by node_id and all its descendants from the document.

  Raises if node_id does not exist in the document.
  """
  @spec delete_node(Document.t(), node_id) :: Document.t() | no_return
  def delete_node(%Document{nodes: nodes, roots: roots} = document, node_id) do
    deleted = [node_id | descendants(document, node_id)]

    roots =
      roots
      |> Enum.reject(&(&1 in deleted))

    nodes =
      nodes
      |> Enum.reduce(nodes, fn {id, node}, nodes ->
        cond do
          id in deleted ->
            Map.delete(nodes, id)

          Map.has_key?(node, :children) ->
            Map.put(nodes, id, %{
              node
              | children: Enum.reject(node.children, &(&1 in deleted))
            })

          true ->
            nodes
        end
      end)

    %{document | roots: roots, nodes: nodes}
  end

  # Inspect

  defimpl Inspect do
    def inspect(_document, _opts) do
      "#Meeseeks.Document<{...}>"
    end
  end
end
