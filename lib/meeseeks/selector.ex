defmodule Meeseeks.Selector do
  @moduledoc """
  Selector structs package some method of checking if a node matches some
  condition with an optional `Meeseeks.Selector.Combinator`, an optional
  list of filter selectors, and an optional method of validating the
  Selector.

  For instance, the css selector `ul > li` contains a selector `ul` and the
  associated combinator `> li`.

  In Meeseeks, this selector could be represented as:

  ```elixir
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.Element

  %Element{
    selectors: [%Element.Tag{value: "ul"}],
    combinator: %Combinator.ChildElements{
      selector: %Element{selectors: [%Element.Tag{value: "li"}]}}}
  ```

  Extending Meeseek's ability to query is as simple as defining a struct
  with the Meeseeks.Selector behaviour, and selectors provide a simple
  target to compile dsls to.

  ## Examples

  ```elixir
  defmodule Selector.Text.Contains do
    use Meeseeks.Selector

    alias Meeseeks.Document

    defstruct value: ""

    def match(selector, %Document.Text{} = text, _document, _context) do
      String.contains?(text.content, selector.value)
    end

    def match(_selector, _node, _document, _context) do
      false
    end
  end
  ```
  """

  alias Meeseeks.{Context, Document, Error, Selector}

  @type t :: struct

  @doc """
  Invoked in order to check if the selector matches the node in the context
  of the document. Can return a boolean or a tuple of a boolean and a
  context.
  """
  @callback match(
              selector :: t,
              node :: Document.node_t(),
              document :: Document.t(),
              context :: Context.t()
            ) :: boolean | {boolean, Context.t()}

  @doc """
  Invoked to return the selector's combinator, or `nil` if it does not have
  one.
  """
  @callback combinator(selector :: t) :: Selector.Combinator.t() | nil

  @doc """
  Invoked to return the selector's filter selectors, which may be an empty
  list, or `nil` if it does not have any.

  Filters are selectors that are applied to a list of any nodes that match
  the selector before they are further walked with the selector's combinator
  if it has one, or accumulated if it does not.
  """
  @callback filters(selector :: t) :: [t] | nil

  @doc """
  Invoked to validate a selector, returning `{:ok, selector}` if the selector
  is valid or `{:error, reason}` if it is not.

  Selector validation can be useful in instances where a selector has been
  built dynamically (parsed from a string, for instance).

  See the `Meeseeks.Selector.Element.PseudoClass.*` selectors for examples.

  Meeseek's selection process doesn't call `validate` anywhere, so there is
  no selection-time cost for providing a validator.
  """
  @callback validate(selector :: t) :: {:ok, t} | {:error, String.t()}

  # match

  @doc """
  Checks if the selector matches the node in the context of the document. Can
  return a boolean or a tuple of a boolean and a context.
  """
  @spec match(t, Document.node_t(), Document.t(), Context.t()) :: boolean | {boolean, Context.t()}
  def match(%{__struct__: struct} = selector, node, document, context) do
    struct.match(selector, node, document, context)
  end

  # combinator

  @doc """
  Returns the selector's combinator, or `nil` if it does not have one.
  """
  @spec combinator(t) :: Selector.Combinator.t() | nil
  def combinator(%{__struct__: struct} = selector) do
    struct.combinator(selector)
  end

  # filters

  @doc """
  Returns the selector's filter selectors, which may be an empty list, or
  `nil` if it does not have any.
  """
  @spec filters(t) :: [t] | nil
  def filters(%{__struct__: struct} = selector) do
    struct.filters(selector)
  end

  # validate

  @doc """
  Validates selector, returning `{:ok, selector}` if the selector is valid or
  `{:error, %Meeseeks.Error{}}` if it is not.
  """
  @spec validate(t) :: {:ok, t} | {:error, Error.t()}
  def validate(%{__struct__: struct} = selector) do
    struct.validate(selector)
  end

  # validate!

  @doc """
  Validates selector, returning the selector if it is valid or raising a
  `Meeseeks.Error` if it is not.
  """
  @spec validate!(t) :: t | no_return
  def validate!(selector) do
    case validate(selector) do
      {:ok, selector} -> selector
      {:error, %Error{} = error} -> raise error
    end
  end

  # __using__

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Selector
      @impl Selector
      def match(_, _, _, _), do: raise("match/4 not implemented")

      @impl Selector
      def combinator(_), do: nil

      @impl Selector
      def filters(_), do: nil

      @impl Selector
      def validate(selector), do: {:ok, selector}

      defoverridable match: 4, combinator: 1, filters: 1, validate: 1
    end
  end
end
