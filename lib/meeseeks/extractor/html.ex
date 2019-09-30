defmodule Meeseeks.Extractor.Html do
  @moduledoc false

  alias Meeseeks.Document

  alias Meeseeks.Document.{
    Comment,
    Data,
    Doctype,
    Element,
    Node,
    ProcessingInstruction,
    Text
  }

  alias Meeseeks.Extractor.Helpers

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

  # from_node

  @spec from_node(Node.t(), Document.t()) :: iodata()
  def from_node(node, document)

  def from_node(%Comment{content: content}, _) do
    ["<!--", content, "-->"]
  end

  def from_node(%Data{type: :cdata, content: content}, _) do
    ["<![CDATA[", content, "]]>"]
  end

  def from_node(%Data{content: content}, _) do
    content
  end

  def from_node(%Doctype{name: name, public: public, system: system}, _) do
    ["<!DOCTYPE ", name, format_legacy(public, system), ">"]
  end

  def from_node(%Element{} = node, document) do
    if node.tag in @self_closing_tags and node.children == [] do
      self_closing_tag(node)
    else
      [opening_tag(node), child_html(node, document), closing_tag(node)]
    end
  end

  def from_node(%ProcessingInstruction{target: target, data: data}, _) do
    ["<?", target, " ", data, "?>"]
  end

  def from_node(%Text{content: content}, _) do
    Helpers.html_escape_text(content)
  end

  # format_legacy

  defp format_legacy("", ""), do: ""

  defp format_legacy(public, ""), do: [" PUBLIC \"", public, "\""]

  defp format_legacy("", system), do: [" SYSTEM \"", system, "\""]

  defp format_legacy(public, system) do
    [" PUBLIC \"", public, "\" \"", system, "\""]
  end

  # self_closing_tag

  defp self_closing_tag(%Element{namespace: ns, tag: tag, attributes: attrs}) do
    tag = full_tag(ns, tag)
    attributes = format_attributes(attrs)
    ["<", tag, attributes, " />"]
  end

  # opening_tag

  defp opening_tag(%Element{namespace: ns, tag: tag, attributes: attrs}) do
    tag = full_tag(ns, tag)
    attributes = format_attributes(attrs)
    ["<", tag, attributes, ">"]
  end

  # child_html

  defp child_html(%Element{id: id}, document) do
    Helpers.child_nodes(document, id)
    |> Enum.map(&from_node(&1, document))
  end

  # closing_tag

  defp closing_tag(%Element{namespace: ns, tag: tag}) do
    tag = full_tag(ns, tag)
    ["</", tag, ">"]
  end

  defp full_tag("", tag), do: tag
  defp full_tag(ns, tag), do: [ns, ":", tag]

  # format_attributes

  defp format_attributes(attributes) do
    Enum.map(attributes, &format_attribute/1)
  end

  defp format_attribute({attribute, value}) do
    escaped_value = Helpers.html_escape_attribute_value(value)
    [" ", attribute, "=\"", escaped_value, "\""]
  end
end
