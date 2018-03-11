defmodule Meeseeks.Document.Doctype do
  use Meeseeks.Document.Node
  @moduledoc false

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, name: "", public: "", system: ""

  @impl true
  def html(node, _document) do
    "<!DOCTYPE #{node.name}#{format_legacy(node.public, node.system)}>"
  end

  @impl true
  def tree(node, _document) do
    {:doctype, node.name, node.public, node.system}
  end

  defp format_legacy("", ""), do: ""
  defp format_legacy(public, ""), do: " PUBLIC \"#{public}\""
  defp format_legacy("", system), do: " SYSTEM \"#{system}\""
  defp format_legacy(public, system), do: " PUBLIC \"#{public}\" \"#{system}\""
end
