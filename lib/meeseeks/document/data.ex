defmodule Meeseeks.Document.Data do
  use Meeseeks.Document.Node
  @moduledoc false

  alias Meeseeks.Document.{Data, Helpers}

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, type: nil, content: ""

  @impl true
  def data(node, _document) do
    Helpers.collapse_whitespace(node.content)
  end

  @impl true
  def html(%Data{type: :cdata, content: content}, _document) do
    "<![CDATA[#{content}]]>"
  end

  @impl true
  def html(node, _document) do
    node.content
  end

  @impl true
  def tree(node, _document) do
    node.content
  end
end
