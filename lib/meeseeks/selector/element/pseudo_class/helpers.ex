defmodule Meeseeks.Selector.Element.PseudoClass.Helpers do
  @moduledoc false

  alias Meeseeks.Document

  def index(element, document) do
    element
    |> siblings(document)
    |> Enum.find_index(fn id -> id == element.id end)
    |> plus_one()
  end

  def index_of_type(element, document) do
    element
    |> siblings_of_type(document)
    |> Enum.find_index(fn id -> id == element.id end)
    |> plus_one()
  end

  def backwards_index(element, document) do
    element
    |> siblings(document)
    |> Enum.reverse()
    |> Enum.find_index(fn id -> id == element.id end)
    |> plus_one()
  end

  def backwards_index_of_type(element, document) do
    element
    |> siblings_of_type(document)
    |> Enum.reverse()
    |> Enum.find_index(fn id -> id == element.id end)
    |> plus_one()
  end

  def siblings(element, document) do
    document
    |> Document.siblings(element.id)
    |> Enum.filter(fn n ->
      Document.element?(document, n)
    end)
  end

  def siblings_of_type(element, document) do
    document
    |> Document.siblings(element.id)
    |> Enum.filter(fn id ->
      case Document.get_node(document, id) do
        %Document.Element{tag: tag} -> tag == element.tag
        _ -> false
      end
    end)
  end

  defp plus_one(nil), do: nil
  defp plus_one(n), do: n + 1

  def nth?(index, a, b) do
    if a == 0 do
      index == b
    else
      (index - b) * a >= 0 and rem(index - b, a) == 0
    end
  end
end
