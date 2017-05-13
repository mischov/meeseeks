defmodule Meeseeks.Selector.XPath.Expr.NameTest do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Document
  alias Meeseeks.Selector.XPath.Expr.NameTest

  defstruct namespace: nil, tag: nil

  def eval(%NameTest{namespace: nil, tag: "*"}, %Document.Element{}, _document, _context) do
    true
  end

  def eval(%NameTest{namespace: ns, tag: "*"}, %Document.Element{} = element, _document, _context) do
    element.namespace == ns
  end

  def eval(%NameTest{namespace: ns, tag: nil}, %Document.Element{} = element, _document, _context) do
    element.namespace == ns
  end

  def eval(%NameTest{namespace: nil, tag: tag}, %Document.Element{} = element, _document, _context) do
    element.tag == tag
  end

  def eval(%NameTest{namespace: ns, tag: tag}, %Document.Element{} = element, _document, _context) do
    element.namespace == ns and element.tag == tag
  end

  def eval(_expr, _element, _document, _context) do
    false
  end
end
