defmodule Meeseeks.Selector.Combinator do
  @moduledoc """
  Combinator structs package some method for finding related nodes and a
  `Meeseeks.Selector` to be run on found nodes.

  For instance, the css selector `ul > li` contains the combinator `> li`,
  which roughly translates to "find a node's children and match any that are
  `li`s."

  In Meeseeks, this combinator could be represented as:

  ```elixir
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.Element

  %Combinator.ChildElements{
    selector: %Element{selectors: [%Element.Tag{value: "li"}]}}
  ```

  When defining a combinator using `use Meeseeks.Selector.Combinator`, the
  default implementation of `selector/1` expects the selector to be stored
  in field `selector`. If this is different in your struct, you must
  implement `selector/1`.

  ## Examples

  ```elixir
  defmodule Selector.Combinator.Parent do
    use Meeseeks.Selector.Combinator

    defstruct selector: nil

    def next(_combinator, node, _document) do
      node.parent
    end
  end
  ```
  """

  alias Meeseeks.{Document, Selector}

  @type t :: struct

  @doc """
  Invoked in order to find the node or nodes that a combinator wishes its
  selector to be run on.

  Returns the applicable node or nodes, or `nil` if there are no applicable
  nodes.
  """
  @callback next(combinator :: t, node :: Document.node_t(), document :: Document.t()) ::
              [Document.node_t()]
              | Document.node_t()
              | nil

  @doc """
  Invoked to return the combinator's selector.
  """
  @callback selector(combinator :: t) :: Selector.t()

  # next

  @doc """
  Finds the node or nodes that a combinator wishes its selector to be run on.

  Returns the applicable node or nodes, or `nil` if there are no applicable
  nodes.
  """
  @spec next(t, Document.node_t(), Document.t()) :: [Document.node_t()] | Document.node_t() | nil
  def next(%{__struct__: struct} = combinator, node, document) do
    struct.next(combinator, node, document)
  end

  # combinator

  @doc """
  Returns the combinator's selector.
  """
  @spec selector(t) :: Selector.t()
  def selector(%{__struct__: struct} = combinator) do
    struct.selector(combinator)
  end

  # __using__

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Selector.Combinator

      @impl Selector.Combinator
      def next(_, _, _), do: raise("next/3 not implemented")

      @impl Selector.Combinator
      def selector(combinator), do: combinator.selector

      defoverridable next: 3, selector: 1
    end
  end
end
