defmodule Meeseeks.Selector.XPath.Expr.NodeType do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr.NodeType

  defstruct type: nil

  def eval(%NodeType{type: :comment}, %Document.Comment{}, _document, _context) do
    true
  end

  def eval(%NodeType{type: :node}, _node, _document, _context) do
    true
  end

  def eval(%NodeType{type: :"processing-instruction"}, %Document.ProcessingInstruction{}, _document, _context) do
    true
  end

  def eval(%NodeType{type: :text}, %Document.Data{}, _document, _context) do
    true
  end

  def eval(%NodeType{type: :text}, %Document.Text{}, _document, _context) do
    true
  end

  def eval(_expr, _node, _document, _context) do
    false
  end
end
