defmodule Meeseeks.Selector.XPath.Expr.ProcessingInstruction do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  defstruct name: nil

  def eval(_expr, _node, _document, _context) do
    false # currently not supported because html5ever will parse as comments
  end
end
