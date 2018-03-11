defmodule Meeseeks.Document.Node do
  @moduledoc false

  alias Meeseeks.{Document, TupleTree}

  @type t :: struct

  @callback attr(node :: t, attribute :: String.t()) :: String.t() | nil

  @callback attrs(node :: t) :: [{String.t(), String.t()}] | nil

  @callback data(node :: t, document :: Document.t()) :: String.t()

  @callback html(node :: t, document :: Document.t()) :: String.t()

  @callback own_text(node :: t, document :: Document.t()) :: String.t()

  @callback tag(node :: t) :: String.t() | nil

  @callback text(node :: t, document :: Document.t()) :: String.t()

  @callback tree(node :: t, document :: Document.t()) :: TupleTree.node_t()

  # attr

  @spec attr(t, String.t()) :: String.t() | nil
  def attr(%{__struct__: struct} = node, attribute) do
    struct.attr(node, attribute)
  end

  # attrs

  @spec attrs(t) :: [{String.t(), String.t()}] | nil
  def attrs(%{__struct__: struct} = node) do
    struct.attrs(node)
  end

  # data

  @spec data(t, Document.t()) :: String.t()
  def data(%{__struct__: struct} = node, document) do
    struct.data(node, document)
  end

  # html

  @spec html(t, Document.t()) :: String.t()
  def html(%{__struct__: struct} = node, document) do
    struct.html(node, document)
  end

  # own_text

  @spec own_text(t, Document.t()) :: String.t()
  def own_text(%{__struct__: struct} = node, document) do
    struct.own_text(node, document)
  end

  # tag

  @spec tag(t) :: String.t() | nil
  def tag(%{__struct__: struct} = node) do
    struct.tag(node)
  end

  # text

  @spec text(t, Document.t()) :: String.t()
  def text(%{__struct__: struct} = node, document) do
    struct.text(node, document)
  end

  # tree

  @spec tree(t, Document.t()) :: TupleTree.node_t()
  def tree(%{__struct__: struct} = node, document) do
    struct.tree(node, document)
  end

  # __using__

  defmacro __using__(_) do
    quote do
      @behaviour Document.Node

      @impl Document.Node
      def attr(_, _), do: nil

      @impl Document.Node
      def attrs(_), do: nil

      @impl Document.Node
      def data(_, _), do: ""

      @impl Document.Node
      def html(_, _), do: raise("html/2 not implemented")

      @impl Document.Node
      def own_text(_, _), do: ""

      @impl Document.Node
      def tag(_), do: nil

      @impl Document.Node
      def text(_, _), do: ""

      @impl Document.Node
      def tree(_, _), do: raise("tree/2 not implemented")

      defoverridable Document.Node
    end
  end
end
