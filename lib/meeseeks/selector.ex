defmodule Meeseeks.Selector do
  @moduledoc """
  Selector structs package some method of checking if a node matches some
  condition with an (optional) `Meeseeks.Selector.Combinator` and an
  (optional) method of validating the Selector.

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

    def match?(selector, %Document.Text{} = text, _document) do
      String.contains?(text.content, selector.value)
    end

    def match?(_selector, _node, _document) do
      false
    end
  end
  ```
  """

  alias Meeseeks.{Document, Selector}

  defmodule InvalidSelectorError do
    @moduledoc false

    defexception [:message]
  end

  @type t :: struct

  @doc """
  Invoked in order to check if the selector matches the node in the context
  of the document.
  """
  @callback match?(selector :: t, node :: Document.node_t, document :: Document.t) :: boolean

  @doc """
  Invoked to return the selector's combinator, or `nil` if it does not have
  one.
  """
  @callback combinator(selector :: t) :: Selector.Combinator.t | nil

  @doc """
  Invoked to validate a selector, returning `{:ok, selector}` if the selector
  is valid or `{:error, reason}` if it is not.

  Selector validation can be useful in instances where a selector has been
  built dynamically (parsed from a string, for instance).

  See the `Meeseeks.Selector.Element.PseudoClass.*` selectors for examples.

  Meeseek's selection process doesn't call `validate` anywhere, so there is
  no selection-time cost for providing a validator.
  """
  @callback validate(selector :: t) :: {:ok, t} | {:error, String.t}

  # match?

  @doc """
  Checks if the selector matches the node in the context of the document.
  """
  @spec match?(t, Document.node_t, Document.t) :: boolean
  def match?(%{__struct__: struct} = selector, node, document) do
    struct.match?(selector, node, document)
  end

  # combinator

  @doc """
  Returns the selector's combinator, or `nil` if it does not have one.
  """
  @spec combinator(t) :: Selector.Combinator.t | nil
  def combinator(%{__struct__: struct} = selector) do
    struct.combinator(selector)
  end

  # validate

  @doc """
  Validates selector, returning `{:ok, selector}` if the selector is valid or
  `{:error, reason}` if it is not.
  """
  @spec validate(t) :: {:ok, t} | {:error, String.t}
  def validate(%{__struct__: struct} = selector) do
    struct.validate(selector)
  end

  # validate!

  @doc """
  Validates selector, returning the selector if it is valid or raising a
  Meeseeks.Selector.InvalidSelectorError if it is not.
  """
  def validate!(selector) do
    case validate(selector) do
      {:ok, selector} -> selector
      {:error, reason} -> raise InvalidSelectorError, reason
    end
  end

  # __using__

  @doc false
  defmacro __using__(_) do
    quote do
      @behaviour Selector
      def match?(_, _, _), do: raise "match?/3 not implemented"
      def combinator(_), do: nil
      def validate(selector), do: {:ok, selector}
      defoverridable match?: 3, combinator: 1, validate: 1
    end
  end
end
