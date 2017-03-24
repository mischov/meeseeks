defmodule Meeseeks.Document.Data do
  @moduledoc false

  use Meeseeks.Document.Node

  alias Meeseeks.Document.Helpers

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, content: ""

  def data(node, _document) do
    Helpers.collapse_whitespace(node.content)
  end

  def html(node, _document) do
    node.content
  end

  def tree(node, _document) do
    node.content
  end
end
