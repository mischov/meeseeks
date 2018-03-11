defmodule Meeseeks.Selector.XPath.Expr.NamespaceNameTest do
  use Meeseeks.Selector.XPath.Expr
  @moduledoc false

  alias Meeseeks.Selector.XPath.Expr.NamespaceNameTest

  # Not currently resolving prefix to namespace-uri

  # Name == namespace, namespace should always be empty or nil
  defstruct namespace: nil, name: nil

  @impl true
  def eval(%NamespaceNameTest{namespace: nil, name: "*"}, _ns, _document, _context) do
    true
  end

  def eval(%NamespaceNameTest{namespace: nil, name: name}, ns, _document, _context) do
    name == ns
  end

  def eval(%NamespaceNameTest{namespace: "", name: name}, ns, _document, _context) do
    name == ns
  end

  def eval(_expr, _element, _document, _context) do
    false
  end
end
