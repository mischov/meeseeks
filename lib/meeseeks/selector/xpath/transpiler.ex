defmodule Meeseeks.Selector.XPath.Transpiler do
  @moduledoc false

  alias Meeseeks.Selector
  alias Meeseeks.Selector.{Combinator, XPath}

  # to_selectors

  def to_selectors(%XPath.Expr.Filter{}) do
    raise "XPath filter expressions are not supported outside of predicates"
  end

  def to_selectors(%XPath.Expr.Union{e1: e1, e2: e2}) do
    List.flatten([to_selectors(e1), to_selectors(e2)])
  end

  def to_selectors(%XPath.Expr.Path{type: :abs, steps: steps}) do
    case combine_steps(Enum.reverse(steps)) do
      %Combinator.Self{selector: %{combinator: c, selectors: s}} ->
        %Selector.Root{combinator: c, selectors: s}

      %Combinator.DescendantsOrSelf{
        selector: %Selector.Element{
          combinator: %Combinator.Children{} = c,
          selectors: [],
          filters: nil
        }
      } ->
        %Selector.Element{combinator: c}

      c ->
        %Selector.Root{combinator: c}
    end
  end

  def to_selectors(%XPath.Expr.Path{type: :rel, steps: steps}) do
    case combine_steps(Enum.reverse(steps)) do
      %Combinator.Self{selector: selector} -> selector
      %Combinator.Children{} = c -> %Selector.Element{combinator: c}
      %Combinator.Descendants{} = c -> %Selector.Element{combinator: c}
      c -> %Selector.Node{combinator: c}
    end
  end

  # combine_steps

  defp combine_steps(steps) do
    Enum.reduce(steps, nil, fn step, combinator ->
      selector = combine_predicates(step.predicates, combinator)
      %{step.combinator | selector: selector}
    end)
  end

  # combine_predicates

  defp combine_predicates([selector_expr | filter_exprs], combinator) do
    filters =
      case Enum.map(filter_exprs, &predicate/1) do
        [] -> nil
        filters -> filters
      end

    selector(selector_expr, combinator, filters)
  end

  # selector

  defp selector(%XPath.Expr.NameTest{} = expr, combinator, filters) do
    %Selector.Element{
      selectors: name_test_selectors(expr),
      combinator: combinator,
      filters: filters
    }
  end

  defp selector(expr, %Combinator.Children{} = combinator, filters) do
    %Selector.Element{
      selectors: selectors_from_expr(expr),
      combinator: combinator,
      filters: filters
    }
  end

  defp selector(expr, %Combinator.Descendants{} = combinator, filters) do
    %Selector.Element{
      selectors: selectors_from_expr(expr),
      combinator: combinator,
      filters: filters
    }
  end

  defp selector(expr, combinator, filters) do
    %Selector.Node{selectors: selectors_from_expr(expr), combinator: combinator, filters: filters}
  end

  # selectors_from_expr

  defp selectors_from_expr(%XPath.Expr.NameTest{} = expr) do
    name_test_selectors(expr)
  end

  defp selectors_from_expr(%XPath.Expr.NodeType{} = expr) do
    node_type_selectors(expr)
  end

  defp selectors_from_expr(expr) do
    [predicate(expr)]
  end

  # name_test_selectors

  defp name_test_selectors(%XPath.Expr.NameTest{namespace: ns, tag: nil}) do
    [%Selector.Element.Namespace{value: ns}]
  end

  defp name_test_selectors(%XPath.Expr.NameTest{namespace: nil, tag: tag}) do
    [%Selector.Element.Tag{value: tag}]
  end

  defp name_test_selectors(%XPath.Expr.NameTest{namespace: ns, tag: tag}) do
    [%Selector.Element.Namespace{value: ns}, %Selector.Element.Tag{value: tag}]
  end

  # node_type_selectors

  defp node_type_selectors(%XPath.Expr.NodeType{type: :node}) do
    []
  end

  defp node_type_selectors(expr) do
    [predicate(expr)]
  end

  # predicate

  defp predicate(expr) do
    %XPath.Predicate{e: expr}
  end
end
