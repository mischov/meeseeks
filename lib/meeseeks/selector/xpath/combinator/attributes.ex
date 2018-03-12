defmodule Meeseeks.Selector.XPath.Combinator.Attributes do
  use Meeseeks.Selector.Combinator
  @moduledoc false

  alias Meeseeks.Document

  defstruct selector: nil

  @impl true
  def next(_combinator, %Document.Element{} = element, _document) do
    element.attributes
  end

  def next(_combinator, _node, _document) do
    nil
  end
end
