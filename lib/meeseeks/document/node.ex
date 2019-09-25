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

  @spec data(t, Document.t()) :: String.t()
  def data(node, document) do
    Extractor.Data.from_node(node, document)
    |> Extractor.Helpers.collapse_whitespace()
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  # html

  @spec html(t, Document.t()) :: String.t()
  def html(node, document) do
    Extractor.Html.from_node(node, document)
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  # own_text

  @spec own_text(t, Document.t()) :: String.t()
  def own_text(node, document) do
    Extractor.OwnText.from_node(node, document)
    |> Extractor.Helpers.collapse_whitespace()
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  # tag

  @spec tag(t) :: String.t() | nil
  def tag(node) do
    Extractor.Tag.from_node(node)
  end

  # text

  @spec text(t, Document.t()) :: String.t()
  def text(node, document) do
    Extractor.Text.from_node(node, document)
    |> Extractor.Helpers.collapse_whitespace()
    |> IO.iodata_to_binary()
    |> String.trim()
  end

  # tree

  @spec tree(t, Document.t()) :: TupleTree.node_t()
  def tree(node, document) do
    Extractor.Tree.from_node(node, document)
  end
end
