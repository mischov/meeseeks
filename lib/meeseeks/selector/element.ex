defmodule Meeseeks.Selector.Element do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.{Attribute, Combinator, Element, Pseudo}

  defstruct(
    namespace: nil,
    tag: nil,
    attributes: [],
    pseudo: nil,
    combinator: nil
  )

  @type t :: %Element{namespace: String.t | nil,
                      tag: String.t | nil,
                      attributes: [Attribute.t],
                      pseudo: Pseudo.t | nil,
                      combinator: Combinator.t | nil}

  @spec match?(Document.t, Document.node_t, t) :: boolean

  def match?(_document, %Document.Comment{}, _selector) do
    false
  end

  def match?(_document, %Document.Text{}, _selector) do
    false
  end

  def match?(_document, %Document.Data{}, _selector) do
    false
  end

  def match?(document, element, selector) do
    namespace_match?(element, selector.namespace)
    && tag_match?(element, selector.tag)
    && attributes_match?(element, selector.attributes)
    && pseudo_match?(document, element, selector.pseudo)
  end

  defp namespace_match?(_element, nil) do
    true
  end

  defp namespace_match?(_element, "*") do
    true
  end

  defp namespace_match?(%Document.Element{namespace: ns}, namespace) do
    ns == namespace
  end

  defp tag_match?(_element, nil) do
    true
  end

  defp tag_match?(_element, "*") do
    true
  end

  defp tag_match?(%Document.Element{tag: tg}, tag) do
    tg == tag
  end

  defp attributes_match?(_element, []) do
    true
  end

  defp attributes_match?(%Document.Element{attributes: []}, _attribute_selectors) do
    false
  end

  defp attributes_match?(%Document.Element{attributes: attributes}, attribute_selectors) do
    Enum.all?(attribute_selectors, &(Attribute.match?(attributes, &1)))
  end

  defp pseudo_match?(_context, _element, nil) do
    true
  end

  defp pseudo_match?(context, element, pseudo) do
    Pseudo.match?(context, element, pseudo)
  end
end
