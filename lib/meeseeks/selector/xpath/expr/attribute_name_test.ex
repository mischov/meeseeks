defmodule Meeseeks.Selector.XPath.Expr.AttributeNameTest do
  @moduledoc false

  use Meeseeks.Selector.XPath.Expr

  alias Meeseeks.Selector.XPath.Expr.AttributeNameTest

  defstruct namespace: nil, name: nil

  def eval(%AttributeNameTest{namespace: nil, name: "*"}, {_attr, _val}, _document, _context) do
    true
  end

  def eval(%AttributeNameTest{namespace: ns, name: "*"}, {attr, _val}, _document, _context) do
    case String.split(attr, ":", parts: 2) do
      [_name] -> false
      [namespace, _name] -> namespace == ns
    end
  end

  def eval(%AttributeNameTest{namespace: ns, name: nil}, {attr, _val}, _document, _context) do
    case String.split(attr, ":", parts: 2) do
      [_name] -> false
      [namespace, _name] -> namespace == ns
    end
  end

  def eval(%AttributeNameTest{namespace: nil, name: name}, {attr, _val}, _document, _context) do
    case String.split(attr, ":", parts: 2) do
      [local_name] -> local_name == name
      [_namespace, local_name] -> local_name == name
    end
  end

  def eval(%AttributeNameTest{namespace: ns, name: name}, {attr, _val}, _document, _context) do
    attr == ns <> ":" <> name
  end

  def eval(_expr, _element, _document, _context) do
    false
  end
end
