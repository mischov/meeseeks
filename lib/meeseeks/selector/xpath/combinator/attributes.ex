defmodule Meeseeks.Selector.XPath.Combinator.Attributes do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{} = element, _document) do
    element.attributes
  end

  def next(_combinator, _node, _document) do
    nil
  end
end
