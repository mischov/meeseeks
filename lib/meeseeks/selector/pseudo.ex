defmodule Meeseeks.Selector.Pseudo do
  @moduledoc false

  alias Meeseeks.Document
  alias Meeseeks.Selector.Element
  alias Meeseeks.Selector.Pseudo

  defstruct(
    match: nil,
    args: []
  )

  @type match :: :first_child
               | :first_of_type
               | :last_child
               | :last_of_type
               | :not
               | :nth_child
               | :nth_last_child
               | :nth_last_of_type
               | :nth_of_type
  @type t :: %Pseudo{match: match | nil,
                     args: [any]}

  # Match?

  @spec match?(Document.t, Document.node_t, t) :: boolean

  ## Can only match Elements

  def match?(_document, %Document.Comment{}, _selector) do
    false
  end

  def match?(_document, %Document.Text{}, _selector) do
    false
  end

  def match?(_document, %Document.Data{}, _selector) do
    false
  end

  ## First Child

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :first_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :first_child}) do
    element.id == first_sibling(element, document)
  end

  ## First of Type

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :first_of_type}) do
    false
  end

  def match?(document, element, %Pseudo{match: :first_of_type}) do
    element.id == first_sibling_of_type(element, document)
  end

  ## Last Child

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :last_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :last_child}) do
    element.id == last_sibling(element, document)
  end

  ## Last of Type

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :last_of_type}) do
    false
  end

  def match?(document, element, %Pseudo{match: :last_of_type}) do
    element.id == last_sibling_of_type(element, document)
  end

  ## Not

  def match?(document, element, %Pseudo{match: :not, args: [%Element{} = sel]}) do
    !Element.match?(document, element, sel)
  end

  ## Nth Child

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :nth_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :nth_child, args: [x]}) do
    index = index(element, document)
    nth?(index, x)
  end

  def match?(document, element, %Pseudo{match: :nth_child, args: [a, b]}) when is_integer(a) and is_integer(b) do
    index = index(element, document)
    nth?(index, a, b)
  end

  ## Nth Last Child

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :nth_last_child}) do
    false
  end

  def match?(document, element, %Pseudo{match: :nth_last_child, args: [x]}) do
    index = backwards_index(element, document)
    nth?(index, x)
  end

  def match?(document, element, %Pseudo{match: :nth_last_child, args: [a, b]}) when is_integer(a) and is_integer(b) do
    index = backwards_index(element, document)
    nth?(index, a, b)
  end

  ## Nth Last Of Type

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :nth_last_of_type}) do
    false
  end

  def match?(document, element, %Pseudo{match: :nth_last_of_type, args: [x]}) do
    index = backwards_index_of_type(element, document)
    nth?(index, x)
  end

  def match?(document, element, %Pseudo{match: :nth_last_of_type, args: [a, b]}) do
    index = backwards_index_of_type(element, document)
    nth?(index, a, b)
  end

  ## Nth Of Type

  def match?(_document, %Document.Element{parent: nil}, %Pseudo{match: :nth_of_type}) do
    false
  end

  def match?(document, element, %Pseudo{match: :nth_of_type, args: [x]}) do
    index = index_of_type(element, document)
    nth?(index, x)
  end

  def match?(document, element, %Pseudo{match: :nth_of_type, args: [a, b]}) do
    index = index_of_type(element, document)
    nth?(index, a, b)
  end

  # Helpers

  defp index(node, document) do
    node
    |> siblings(document)
    |> Enum.find_index(fn(id) -> id == node.id end)
    |> plus_one
  end

  defp index_of_type(node, document) do
    node
    |> siblings_of_type(document)
    |> Enum.find_index(fn(id) -> id == node.id end)
    |> plus_one
  end

  defp backwards_index(node, document) do
    node
    |> siblings(document)
    |> Enum.reverse()
    |> Enum.find_index(fn(id) -> id == node.id end)
    |> plus_one
  end

  defp backwards_index_of_type(node, document) do
    node
    |> siblings_of_type(document)
    |> Enum.reverse()
    |> Enum.find_index(fn(id) -> id == node.id end)
    |> plus_one
  end

  defp first_sibling(node, document) do
    node
    |> siblings(document)
    |> List.first()
  end

  defp last_sibling(node, document) do
    node
    |> siblings(document)
    |> List.last()
  end

  defp siblings(node, document) do
    document
    |> Document.siblings(node.id)
    |> Enum.filter(fn(n) ->
      Document.element?(document, n)
    end)
  end

  defp first_sibling_of_type(node, document) do
    node
    |> siblings_of_type(document)
    |> List.first()
  end

  defp last_sibling_of_type(node, document) do
    node
    |> siblings_of_type(document)
    |> List.last()
  end

  defp siblings_of_type(node, document) do
    document
    |> Document.siblings(node.id)
    |> Enum.filter(fn(id) ->
      case Document.get_node(document, id) do
        %Document.Element{tag: tag} -> tag == node.tag
        _ -> false
      end
    end)
  end

  defp plus_one(nil), do: nil
  defp plus_one(n), do: n + 1

  defp nth?(index, "even") do
    rem(index, 2) == 0
  end

  defp nth?(index, "odd") do
    rem(index, 2) == 1
  end

  defp nth?(index, n) when is_integer(n) do
    index == n
  end

  defp nth?(index, a, b) when is_integer(a) and is_integer(b) do
    if a == 0 do
      index == b
    else
      (index - b) * a >= 0 and rem((index - b), a) == 0
    end
  end
end
