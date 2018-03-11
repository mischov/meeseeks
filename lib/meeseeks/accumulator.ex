defmodule Meeseeks.Accumulator do
  @moduledoc """
  Accumulator structs package some means of storing nodes selected during
  the selection process along with a method for checking if the selection
  should be terminated early and a method for returning the stored nodes.

  Users will not typically need to define, or even know about, accumulators,
  but for users trying to do things like return selected nodes as Document
  nodes (or even tuple-tree nodes) instead of as Results, a custom accumulator
  will provide the solution.
  """

  alias Meeseeks.{Accumulator, Document}

  @type t :: struct

  @doc """
  Invoked to add a selected node to the accumulator.
  """
  @callback add(accumulator :: t, document :: Document.t(), id :: Document.node_id()) :: t

  @doc """
  Invoked to determine if the accumulator is satisfied.
  """
  @callback complete?(accumulator :: t) :: boolean

  @doc """
  Invoked to return the accumulation.
  """
  @callback return(accumulator :: t) :: any

  # add

  @doc """
  Provided a document and a node id, returns an updated accumulator.
  """
  @spec add(t, Document.t(), Document.node_id()) :: t
  def add(%{__struct__: struct} = accumulator, document, id) do
    struct.add(accumulator, document, id)
  end

  # complete?

  @doc """
  Checks if an accumulator has reached an arbitrary state of completion and
  no longer wishes to be added to.
  """
  @spec complete?(t) :: boolean
  def complete?(%{__struct__: struct} = accumulator) do
    struct.complete?(accumulator)
  end

  # return

  @doc """
  Returns the values accumulated by the accumulator.
  """
  @spec return(t) :: any
  def return(%{__struct__: struct} = accumulator) do
    struct.return(accumulator)
  end

  # __using__

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Accumulator

      @impl Accumulator
      def add(_, _, _), do: raise("add/3 not implemented")

      @impl Accumulator
      def complete?(_), do: false

      @impl Accumulator
      def return(_), do: raise("return/1 not implemented")

      defoverridable Accumulator
    end
  end
end
