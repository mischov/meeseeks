defmodule Meeseeks.Selector.CSS.Parser do
  @moduledoc false

  alias Meeseeks.{Error, Selector}
  alias Meeseeks.Selector.{Combinator, Element}
  alias Meeseeks.Selector.Element.{Attribute, Namespace, PseudoClass, Tag}

  # Parse Elements

  def parse_elements(toks) do
    parse_elements(toks, [])
  end

  defp parse_elements([], elements) do
    Enum.reverse(elements)
  end

  defp parse_elements(toks, elements) do
    {element, toks} = parse_element(toks)
    parse_elements(toks, [element | elements])
  end

  # Parse Element

  defp parse_element(toks) do
    parse_element(toks, %Element{})
  end

  defp parse_element([], element) do
    element = %{element | selectors: Enum.reverse(element.selectors)}
    {element, []}
  end

  defp parse_element([',' | toks], element) do
    element = %{element | selectors: Enum.reverse(element.selectors)}
    {element, toks}
  end

  defp parse_element([{:ident, namespace}, '|' | toks], element) do
    selector = %Namespace{value: List.to_string(namespace)}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element(['*', '|' | toks], element) do
    selector = %Namespace{value: "*"}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element([{:ident, tag} | toks], element) do
    selector = %Tag{value: List.to_string(tag)}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element(['*' | toks], element) do
    selector = %Tag{value: "*"}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element([{:id, id} | toks], element) do
    selector = %Attribute.Value{attribute: "id", value: List.to_string(id)}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element([{:class, class} | toks], element) do
    selector = %Attribute.ValueIncludes{attribute: "class", value: List.to_string(class)}
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element(['[' | toks], element) do
    {selector, toks} = parse_attribute(toks)
    element = %{element | selectors: [selector | element.selectors]}
    parse_element(toks, element)
  end

  defp parse_element([':' | toks], element) do
    {selector, toks} = parse_pseudo_class(toks)
    element = %{element | selectors: [selector | element.selectors]}
    Selector.validate!(selector)
    parse_element(toks, element)
  end

  defp parse_element(['>' | toks], element) do
    {combinator_selector, toks} = parse_element(toks)
    combinator = %Combinator.ChildElements{selector: combinator_selector}
    element = %{element | combinator: combinator}
    parse_element([',' | toks], element)
  end

  defp parse_element([:space | toks], element) do
    {combinator_selector, toks} = parse_element(toks)
    combinator = %Combinator.DescendantElements{selector: combinator_selector}
    element = %{element | combinator: combinator}
    parse_element([',' | toks], element)
  end

  defp parse_element(['+' | toks], element) do
    {combinator_selector, toks} = parse_element(toks)
    combinator = %Combinator.NextSiblingElement{selector: combinator_selector}
    element = %{element | combinator: combinator}
    parse_element([',' | toks], element)
  end

  defp parse_element(['~' | toks], element) do
    {combinator_selector, toks} = parse_element(toks)
    combinator = %Combinator.NextSiblingElements{selector: combinator_selector}
    element = %{element | combinator: combinator}
    parse_element([',' | toks], element)
  end

  # Parse Attribute

  @attribute_value_selector_types [
    :value,
    :value_contains,
    :value_dash,
    :value_includes,
    :value_prefix,
    :value_suffix
  ]

  defp parse_attribute(['^', {:ident, attr}, ']' | toks]) do
    selector = %Attribute.AttributePrefix{attribute: List.to_string(attr)}
    {selector, toks}
  end

  defp parse_attribute([{:ident, attr}, type, {:ident, val}, ']' | toks])
       when type in @attribute_value_selector_types do
    selector = attribute_value_selector(type, List.to_string(attr), List.to_string(val))
    {selector, toks}
  end

  defp parse_attribute([{:ident, attr}, type, {:string, val}, ']' | toks])
       when type in @attribute_value_selector_types do
    selector = attribute_value_selector(type, List.to_string(attr), List.to_string(val))
    {selector, toks}
  end

  defp parse_attribute([{:ident, attr}, ']' | toks]) do
    selector = %Attribute.Attribute{attribute: List.to_string(attr)}
    {selector, toks}
  end

  defp attribute_value_selector(type, attr, val) do
    case type do
      :value -> %Attribute.Value{attribute: attr, value: val}
      :value_contains -> %Attribute.ValueContains{attribute: attr, value: val}
      :value_dash -> %Attribute.ValueDash{attribute: attr, value: val}
      :value_includes -> %Attribute.ValueIncludes{attribute: attr, value: val}
      :value_prefix -> %Attribute.ValuePrefix{attribute: attr, value: val}
      :value_suffix -> %Attribute.ValueSuffix{attribute: attr, value: val}
    end
  end

  # Parse Pseudo Class

  defp parse_pseudo_class([{:ident, type} | toks]) do
    selector = pseudo_class_selector(type, [])
    {selector, toks}
  end

  defp parse_pseudo_class([{:function, type} | toks]) do
    {args, toks} = parse_pseudo_class_args(type, toks)
    selector = pseudo_class_selector(type, args)
    {selector, toks}
  end

  defp parse_pseudo_class_args('not', toks) do
    parse_not_args(toks, 0, [])
  end

  defp parse_pseudo_class_args(type, toks) do
    parse_pseudo_class_args(type, toks, [])
  end

  defp parse_pseudo_class_args(_type, [')' | toks], args) do
    {Enum.reverse(args), toks}
  end

  defp parse_pseudo_class_args(type, [{:int, arg} | toks], args) do
    parse_pseudo_class_args(type, toks, [List.to_integer(arg) | args])
  end

  defp parse_pseudo_class_args(type, [{:ident, arg} | toks], args) do
    parse_pseudo_class_args(type, toks, [List.to_string(arg) | args])
  end

  defp parse_pseudo_class_args(type, [{:string, arg} | toks], args) do
    parse_pseudo_class_args(type, toks, [List.to_string(arg) | args])
  end

  defp parse_pseudo_class_args(type, [{:ab_formula, arg} | toks], args) do
    case Regex.run(~r/\s*([\+\-])?\s*(\d+)?[nN]\s*(([\+\-])\s*(\d+))?\s*/, List.to_string(arg)) do
      [_] ->
        parse_pseudo_class_args(type, toks, [0, 1 | args])

      [_, a_op] ->
        a = parse_a(a_op)
        parse_pseudo_class_args(type, toks, [0, a | args])

      [_, a_op, a_str] ->
        a = parse_a(a_op <> a_str)
        parse_pseudo_class_args(type, toks, [0, a | args])

      [_, a_op, a_str, _, b_op, b_str] ->
        a = parse_a(a_op <> a_str)
        b = parse_b(b_op <> b_str)
        parse_pseudo_class_args(type, toks, [b, a | args])
    end
  end

  defp parse_a(a_str) do
    case String.replace(a_str, "+", "") do
      "" -> 1
      "-" -> -1
      str -> String.to_integer(str)
    end
  end

  defp parse_b(b_str) do
    b_str
    |> String.replace("+", "")
    |> String.to_integer()
  end

  defp parse_not_args([')' | toks], 0, acc) do
    tokens = Enum.reverse(acc)
    selectors = parse_elements(tokens)

    {[selectors], toks}
  end

  defp parse_not_args([')' | toks], depth, acc) do
    parse_not_args(toks, depth - 1, [')' | acc])
  end

  defp parse_not_args([{:function, _type} = tok | toks], depth, acc) do
    parse_not_args(toks, depth + 1, [tok | acc])
  end

  defp parse_not_args([tok | toks], depth, acc) do
    parse_not_args(toks, depth, [tok | acc])
  end

  defp pseudo_class_selector(type, args) do
    case type do
      'first-child' ->
        %PseudoClass.FirstChild{args: args}

      'first-of-type' ->
        %PseudoClass.FirstOfType{args: args}

      'last-child' ->
        %PseudoClass.LastChild{args: args}

      'last-of-type' ->
        %PseudoClass.LastOfType{args: args}

      'not' ->
        %PseudoClass.Not{args: args}

      'nth-child' ->
        %PseudoClass.NthChild{args: args}

      'nth-last-child' ->
        %PseudoClass.NthLastChild{args: args}

      'nth-last-of-type' ->
        %PseudoClass.NthLastOfType{args: args}

      'nth-of-type' ->
        %PseudoClass.NthOfType{args: args}

      _ ->
        raise Error.new(:css_selector_parser, :invalid_input, %{
                description: "Pseudo class \"#{type}\" not supported"
              })
    end
  end
end
