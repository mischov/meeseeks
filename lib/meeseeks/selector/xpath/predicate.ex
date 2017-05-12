defmodule Meeseeks.Selector.XPath.Predicate do
  @moduledoc false

  use Meeseeks.Selector

  alias Meeseeks.Selector.XPath.Expr

  defstruct e: nil

  def match(selector, node, document, context) do
    Expr.Helpers.boolean(Expr.eval(selector.e, node, document, context), document)
  end

  def filters(_), do: []
end
