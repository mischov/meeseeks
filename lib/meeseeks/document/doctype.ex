defmodule Meeseeks.Document.Doctype do
  @moduledoc false

  use Meeseeks.Document.Node

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, type: "", public: "", system: ""

  def html(node, _document) do
    "<!DOCTYPE #{node.type}#{format_legacy node.public, node.system}>"
  end

  def tree(node, _document) do
    {:doctype, node.type, node.public, node.system}
  end

  defp format_legacy("", ""), do: ""
  defp format_legacy(public, ""), do: " PUBLIC \"#{public}\""
  defp format_legacy("", system), do: " SYSTEM \"#{system}\""
  defp format_legacy(public, system), do: " PUBLIC \"#{public}\" \"#{system}\""
end
