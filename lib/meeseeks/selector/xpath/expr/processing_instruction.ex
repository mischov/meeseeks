defmodule Meeseeks.Selector.XPath.Expr.ProcessingInstruction do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Document

  defstruct target: nil

  def eval(expr, %Document.ProcessingInstruction{} = pi, _document, _context) do
    pi.target == expr.target
  end

  def eval(_expr, _node, _document, _context) do
    false # currently not supported because html5ever will parse as comments
  end
end
