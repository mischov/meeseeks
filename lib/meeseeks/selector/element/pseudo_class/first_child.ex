defmodule Meeseeks.Selector.Element.PseudoClass.FirstChild do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  def match?(_selector, %Document.Element{parent: nil}, _document) do
    false
  end

  def match?(_selector, %Document.Element{} = element, document) do
    first_sibling = Helpers.siblings(element, document) |> List.first()
    element.id == first_sibling
  end

  def match?(_selector, _node, _document) do
    false
  end

  def validate(selector) do
    case selector.args do
      [] -> {:ok, selector}
      _ -> {:error, ":first-child expects no arguments"}
    end
  end
end
