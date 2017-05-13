defmodule Meeseeks.Selector.XPath.Combinator.Namespaces do
  @moduledoc false

  use Meeseeks.Selector.Combinator

  alias Meeseeks.Document

  defstruct selector: nil

  def next(_combinator, %Document.Element{} = element, _document) do
    element.namespace
  end

  def next(_combinator, _node, _document) do
    nil
  end
end
