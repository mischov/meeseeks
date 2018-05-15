defmodule Meeseeks.Selector.Element.PseudoClass.FirstChild do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.{Document, Error}
  alias Meeseeks.Selector.Element.PseudoClass.Helpers

  defstruct args: []

  @impl true
  def match(_selector, %Document.Element{parent: nil}, _document, _context) do
    false
  end

  def match(_selector, %Document.Element{} = element, document, _context) do
    first_sibling =
      Helpers.siblings(element, document)
      |> List.first()

    element.id == first_sibling
  end

  def match(_selector, _node, _document, _context) do
    false
  end

  @impl true
  def validate(selector) do
    case selector.args do
      [] ->
        {:ok, selector}

      _ ->
        {:error,
         Error.new(:css_selector, :invalid, %{
           description: ":first_child expects to arguments",
           selector: selector
         })}
    end
  end
end
