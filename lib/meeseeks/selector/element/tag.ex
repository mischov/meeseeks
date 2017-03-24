defmodule Meeseeks.Selector.Element.Tag do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element

  defstruct value: nil

  def match?(%Element.Tag{value: "*"}, %Document.Element{}, _document) do
    true
  end

  def match?(selector, %Document.Element{} = element, _document) do
    element.tag == selector.value
  end

  def match?(_selector, _node, _document) do
    false
  end
end
