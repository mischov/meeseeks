defmodule Meeseeks.Context do
  @moduledoc """
  Context is available to both Meeseek's selection process and each
  individual selector, and allows for selectors to build state (or receive
  state from the selection mechanism).

  The selection process expects an `accumulator`, `return?` boolean, and
  `matches` map to exist in the context, and stores selected nodes in the
  `accumulator`, stores matching nodes than need to be filtered in the
  `matches` map, and halts selection if the `return?` boolean becomes true.
  """

  alias Meeseeks.{Accumulator, Document, Selector}

  @accumulator :"__accumulator__"
  @return? :"__return?__"
  @matches :"__matches__"
  @nodes :"__nodes__"

  @type t :: %{optional(any) => any}

  @doc """
  Adds keys required by selection process to the context.

  Used internally by Meeseeks.Select- users should have no reason to call.
  """
  @spec prepare_for_selection(t) :: t
  def prepare_for_selection(context) do
    context
    |> Map.put(@return?, false)
    |> Map.put(@matches, %{})
  end

  @doc """
  Adds an accumulator to context, overriding any existing accumulator in
  context.
  """
  @spec add_accumulator(t, Accumulator.t) :: t
  def add_accumulator(context, acc) do
    Map.put(context, @accumulator, acc)
  end

  @doc """
  Ensures that context contains an accumulator, returning context if it does,
  or raising an error if it does not.
  """
  @spec ensure_accumulator!(t) :: t
  def ensure_accumulator!(context) do
    case Map.fetch(context, @accumulator) do
      {:ok, _} -> context
      :error -> raise "No accumulator in context"
    end
  end

  @doc """
  Updates the context's accumulator with the result of calling
  Accumulator.add on the current accumulator with the provided document and
  id, and sets return? to the result of calling Accumulator.complete? on the
  updated accumulator if return? was not already true.
  """
  @spec add_to_accumulator(t, Document.t, Document.node_id) :: t
  def add_to_accumulator(%{@accumulator => acc, @return? => ret} = context, document, id) do
    acc = Accumulator.add(acc, document, id)
    ret = ret or Accumulator.complete?(acc)
    %{context |
      @accumulator => acc,
      @return? => ret}
  end

  @doc """
  Returns the result of calling Accumulator.return on the context's
  accumulator.
  """
  @spec return_accumulator(t) :: any
  def return_accumulator(%{@accumulator => acc}) do
    Accumulator.return(acc)
  end

  @doc """
  Adds a node to a list in the context's matches map corresponding to the
  selector that the node matched.
  """
  @spec add_to_matches(t, Selector.t, Document.node_t) :: t
  def add_to_matches(%{@matches => matches} = context, selector, node) do
    case Map.fetch(matches, selector) do
      {:ok, nodes} -> put_in(context[@matches][selector], [node|nodes])
      :error -> put_in(context[@matches][selector], [node])
    end
  end

  @doc """
  Clears the context's matches map.
  """
  @spec clear_matches(t) :: t
  def clear_matches(context) do
    Map.put(context, @matches, %{})
  end

  @doc """
  Returns the key under which the accumulator is stored in the context.
  """
  @spec accumulator_key() :: atom
  def accumulator_key() do
    @accumulator
  end

  @doc """
  Returns the key under which return? is stored in the context.
  """
  @spec return_key() :: atom
  def return_key() do
    @return?
  end

  @doc """
  Returns the key under which matching nodes that need to be filtered are
  stored in the context.
  """
  @spec matches_key() :: atom
  def matches_key() do
    @matches
  end

  @doc """
  Returns the key under which the nodes currently being walked are stored in
  the context.
  """
  @spec nodes_key() :: atom
  def nodes_key() do
    @nodes
  end
end
