defmodule Meeseeks.Selector.XPath.Predicate do
  use Meeseeks.Selector
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr

  defstruct e: nil

  @impl true
  def match(selector, node, document, context) do
    Expr.Helpers.boolean(Expr.eval(selector.e, node, document, context), document)
  end

  @impl true
  def filters(_), do: []
end
