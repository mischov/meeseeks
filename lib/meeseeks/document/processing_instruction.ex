defmodule Meeseeks.Document.ProcessingInstruction do
  @moduledoc false

  use Meeseeks.Document.Node

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, target: "", data: ""

  def html(node, _document) do
    "<?#{node.target} #{node.data}?>"
  end

  def tree(node, _document) do
    {:pi, node.target, node.data}
  end
end
