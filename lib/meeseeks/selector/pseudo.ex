defmodule Meeseeks.Selector.Pseudo do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.Pseudo

  defstruct(
    match: nil,
    args: []
  )

  @type match :: :nth_child | :first_child | :last_child
  @type t :: %Pseudo{match: match | nil,
                     args: [any]}

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

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :nth_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :nth_child, args: [n]}) when is_integer(n) do
    index = node_index(element, document)
    index == n
  end

  def match?(document, element, %Pseudo{match: :nth_child, args: ["even"]}) do
    index = node_index(element, document)
    rem(index, 2) == 0
  end

  def match?(document, element, %Pseudo{match: :nth_child, args: ["odd"]}) do
    index = node_index(element, document)
    rem(index, 2) == 1
  end

  def match?(_document, _element, %Pseudo{match: :nth_child}) do
    false
  end

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :first_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :first_child}) do
    element.id == first_sibling(element, document)
  end

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :last_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :last_child}) do
    element.id == last_sibling(element, document)
  end

  defp node_index(node, document) do
    document
    |> Document.siblings(node.id)
    |> Enum.filter(&(Document.element?(document, &1)))
    |> Enum.find_index(fn(id) -> id == node.id end)
    |> plus_one
  end

  defp first_sibling(node, document) do
    document
    |> Document.siblings(node.id)
    |> Enum.filter(&(Document.element?(document, &1)))
    |> List.first
  end

  defp last_sibling(node, document) do
    document
    |> Document.siblings(node.id)
    |> Enum.filter(&(Document.element?(document, &1)))
    |> List.last
  end

  defp plus_one(nil), do: nil
  defp plus_one(n), do: n + 1
end
