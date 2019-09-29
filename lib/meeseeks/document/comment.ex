defmodule Meeseeks.Document.Comment do
  use Meeseeks.Document.Node
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, content: ""

  @impl true
  def html(node, _document) do
    "<!--#{node.content}-->"
  end

  @impl true
  def tree(node, _document) do
    {:comment, node.content}
  end
end
