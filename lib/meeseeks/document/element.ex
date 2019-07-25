defmodule Meeseeks.Document.Element do
  use Meeseeks.Document.Node
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Document.Helpers

  @enforce_keys [:id]
  defstruct parent: nil, id: nil, namespace: "", tag: "", attributes: [], children: []

  @self_closing_tags [
    "area",
    "base",
    "br",
    "col",
    "command",
    "embed",
    "hr",
    "img",
    "input",
    "keygen",
    "link",
    "meta",
    "param",
    "source",
    "track",
    "wbr"
  ]

  @impl true
  def attr(node, attribute) do
    {_attr, value} = List.keyfind(node.attributes, attribute, 0, {nil, nil})
    value
  end

  @impl true
  def attrs(node) do
    node.attributes
  end

  @impl true
  def data(node, document) do
    child_nodes(document, node)
    |> Enum.filter(&data_node?/1)
    |> Enum.reduce("", &join_data(&1, &2, document))
    |> Helpers.collapse_whitespace()
  end

  @impl true
  def html(node, document) do
    if node.tag in @self_closing_tags and node.children == [] do
      self_closing_tag(node)
    else
      opening_tag(node) <> child_html(node, document) <> closing_tag(node)
    end
  end

  @impl true
  def own_text(node, document) do
    child_nodes(document, node)
    |> Enum.filter(&text_node?/1)
    |> Enum.reduce("", &join_text(&1, &2, document))
    |> Helpers.collapse_whitespace()
  end

  @impl true
  def tag(node) do
    node.tag
  end

  @impl true
  def text(node, document) do
    child_nodes(document, node)
    |> Enum.reduce("", &join_text(&1, &2, document))
    |> Helpers.collapse_whitespace()
  end

  @impl true
  def tree(node, document) do
    child_nodes = child_nodes(document, node)
    {node.tag, node.attributes, Enum.map(child_nodes, &Document.Node.tree(&1, document))}
  end

  # Helpers

  defp self_closing_tag(node) do
    tag = full_tag(node.namespace, node.tag)
    attributes = join_attributes(node.attributes)
    "<#{tag}#{attributes} />"
  end

  defp opening_tag(node) do
    tag = full_tag(node.namespace, node.tag)
    attributes = join_attributes(node.attributes)
    "<#{tag}#{attributes}>"
  end

  defp child_html(node, document) do
    child_nodes(document, node)
    |> Enum.reduce("", &join_html(&1, &2, document))
  end

  defp closing_tag(node) do
    tag = full_tag(node.namespace, node.tag)
    "</#{tag}>"
  end

  defp full_tag("", tag), do: tag
  defp full_tag(ns, tag), do: ns <> ":" <> tag

  defp child_nodes(document, node) do
    children = Document.children(document, node.id)

    Document.get_nodes(document, children)
  end

  defp data_node?(%Document.Data{}), do: true
  defp data_node?(_), do: false

  defp text_node?(%Document.Text{}), do: true
  defp text_node?(_), do: false

  defp join_attributes([]) do
    ""
  end

  defp join_attributes(attributes) do
    Enum.reduce(attributes, "", &join_attribute(&1, &2))
  end

  defp join_attribute({attribute, value}, acc) do
    "#{acc} #{attribute}=\"#{Helpers.html_escape_attribute_value(value)}\""
  end

  defp join_data(node, acc, document) do
    case Document.Node.data(node, document) do
      "" -> acc
      data -> "#{acc} #{data}"
    end
  end

  defp join_html(node, acc, document) do
    acc <> Document.Node.html(node, document)
  end

  defp join_text(node, acc, document) do
    case Document.Node.text(node, document) do
      "" -> acc
      text -> "#{acc} #{text}"
    end
  end
end
