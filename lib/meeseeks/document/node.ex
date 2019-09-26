defmodule Meeseeks.Document.Node do
  @moduledoc false

  alias Meeseeks.{Document, Extractor}

  alias Meeseeks.Document.{
    Comment,
    Data,
    Doctype,
    Element,
    ProcessingInstruction,
    Text
  }

  @type t :: struct

  # types

  @types [Comment, Data, Doctype, Element, ProcessingInstruction, Text]

  @spec types() :: [atom]
  def types(), do: @types

  # attr

  @spec attr(t, String.t()) :: String.t() | nil
  def attr(node, attribute) do
    Extractor.Attribute.from_node(node, attribute)
  end

  # attrs

  @spec attrs(t) :: [{String.t(), String.t()}] | nil
  def attrs(node) do
    Extractor.Attributes.from_node(node)
  end

  # data

  @spec data(t, Document.t(), Keyword.t()) :: String.t()
  def data(node, document, opts \\ []) do
    collapse_whitespace? = Keyword.get(opts, :collapse_whitespace, true)
    trim? = Keyword.get(opts, :trim, true)

    Extractor.Data.from_node(node, document)
    |> maybe_collapse_whitespace(collapse_whitespace?)
    |> IO.iodata_to_binary()
    |> maybe_trim(trim?)
  end

  # html

  @spec html(t, Document.t()) :: String.t()
  def html(node, document) do
    Extractor.Html.from_node(node, document)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  # own_text

  @spec own_text(t, Document.t(), Keyword.t()) :: String.t()
  def own_text(node, document, opts \\ []) do
    collapse_whitespace? = Keyword.get(opts, :collapse_whitespace, true)
    trim? = Keyword.get(opts, :trim, true)

    Extractor.OwnText.from_node(node, document)
    |> maybe_collapse_whitespace(collapse_whitespace?)
    |> IO.iodata_to_binary()
    |> maybe_trim(trim?)
  end

  # tag

  @spec tag(t) :: String.t() | nil
  def tag(node) do
    Extractor.Tag.from_node(node)
  end

  # text

  @spec text(t, Document.t(), Keyword.t()) :: String.t()
  def text(node, document, opts \\ []) do
    collapse_whitespace? = Keyword.get(opts, :collapse_whitespace, true)
    trim? = Keyword.get(opts, :trim, true)

    Extractor.Text.from_node(node, document)
    |> maybe_collapse_whitespace(collapse_whitespace?)
    |> IO.iodata_to_binary()
    |> maybe_trim(trim?)
  end

  # tree

  @spec tree(t, Document.t()) :: TupleTree.node_t()
  def tree(node, document) do
    Extractor.Tree.from_node(node, document)
  end

  # maybe_collapse_whitespace

  defp maybe_collapse_whitespace(iodata, collapse_whitespace?)

  defp maybe_collapse_whitespace(iodata, false), do: iodata

  defp maybe_collapse_whitespace(iodata, true) do
    Extractor.Helpers.collapse_whitespace(iodata)
  end

  # maybe_trim

  defp maybe_trim(string, trim?)

  defp maybe_trim(string, false), do: string

  defp maybe_trim(string, true), do: String.trim(string)
end
