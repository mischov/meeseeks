defmodule Meeseeks.Selector.XPath.Expr.ProcessingInstruction do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Document

  defstruct target: nil

  @impl true
  def eval(expr, %Document.ProcessingInstruction{} = pi, _document, _context) do
    pi.target == expr.target
  end

  def eval(_expr, _node, _document, _context) do
    false
  end
end
