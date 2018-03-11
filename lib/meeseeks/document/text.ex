defmodule Meeseeks.Document.Text do
  use Meeseeks.Document.Node
  @moduledoc false

  alias Meeseeks.Document.Helpers

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, content: ""

  @impl true
  def html(node, _document) do
    node.content
  end

  @impl true
  def own_text(node, _document) do
    Helpers.collapse_whitespace(node.content)
  end

  @impl true
  def text(node, _document) do
    Helpers.collapse_whitespace(node.content)
  end

  @impl true
  def tree(node, _document) do
    node.content
  end
end
