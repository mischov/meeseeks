defmodule Meeseeks.Selector.Element.PseudoClass.FirstOfType do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  @impl true
  def match(_selector, %Document.Element{parent: nil}, _document, _context) do
    false
  end

  def match(_selector, %Document.Element{} = element, document, _context) do
    first_of_type =
      Helpers.siblings_of_type(element, document)
      |> List.first()

    element.id == first_of_type
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def validate(selector) do
    case selector.args do
      [] -> {:ok, selector}
      _ -> {:error, ":first-of-type expects no arguments"}
    end
  end
end
