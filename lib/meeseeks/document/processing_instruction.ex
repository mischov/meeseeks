defmodule Meeseeks.Document.ProcessingInstruction do
  use Meeseeks.Document.Node
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, target: "", data: ""

  @impl true
  def html(node, _document) do
    "<?#{node.target} #{node.data}?>"
  end

  @impl true
  def tree(node, _document) do
    {:pi, node.target, node.data}
  end
end
