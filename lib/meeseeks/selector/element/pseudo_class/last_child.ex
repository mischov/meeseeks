defmodule Meeseeks.Selector.Element.PseudoClass.LastChild do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  def match(_selector, %Document.Element{parent: nil}, _document, _context) do
    false
  end

  def match(_selector, %Document.Element{} = element, document, _context) do
    last_sibling = Helpers.siblings(element, document) |> List.last()
    element.id == last_sibling
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  def validate(selector) do
    case selector.args do
      [] -> {:ok, selector}
      _ -> {:error, ":last-child expects no arguments"}
    end
  end
end
