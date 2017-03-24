defmodule Meeseeks.Document.Comment do
  @moduledoc false

  use Meeseeks.Document.Node

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, content: ""

  def html(node, _document) do
    "<!-- #{node.content} -->"
  end

  def tree(node, _document) do
    {:comment, node.content}
  end
end
