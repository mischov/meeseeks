defmodule Meeseeks.Selector.CSS.Parser do
  @moduledoc false

  alias Meeseeks.Selector
  alias Meeseeks.Selector.{Combinator, Element}
  alias Meeseeks.Selector.Element.{Attribute, Namespace, PseudoClass, Tag,}

  defmodule ParseError do
    @moduledoc false

    defexception [:message]
  end

  # Parse Element

  def parse_element(toks) do
    parse_element(toks, %Element{})
  end

  defp parse_element([], element) do
    %{element | selectors: Enum.reverse(element.selectors)}
  end

  defp parse_element([{:ident, namespace}, '|' | toks], element) do
    selector = %Namespace{value: List.to_string(namespace)}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element(['*', '|' | toks], element) do
    selector = %Namespace{value: "*"}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element([{:ident, tag} | toks], element) do
    selector = %Tag{value: List.to_string(tag)}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element(['*' | toks], element) do
    selector = %Tag{value: "*"}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element([{:id, id} | toks], element) do
    selector = %Attribute.Value{
      attribute: "id",
      value: List.to_string(id)}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element([{:class, class} | toks], element) do
    selector = %Attribute.ValueIncludes{
      attribute: "class",
      value: List.to_string(class)}
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element(['[' | toks], element) do
    {selector, toks} = parse_attribute(toks)
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element([':' | toks], element) do
    {selector, toks} = parse_pseudo_class(toks)
    Selector.validate!(selector)
    parse_element(toks, %{element | selectors: [selector|element.selectors]})
  end

  defp parse_element(['>' | toks], element) do
    combinator = %Combinator.ChildElements{
      selector: parse_element(toks)
    }
    (parse_element [], %{element | combinator: combinator})
  end

  defp parse_element([:space | toks], element) do
    combinator = %Combinator.DescendantElements{
      selector: parse_element(toks)
    }
    (parse_element [], %{element | combinator: combinator})
  end

  defp parse_element(['+' | toks], element) do
    combinator = %Combinator.NextSiblingElement{
      selector: parse_element(toks)
    }
    (parse_element [], %{element | combinator: combinator})
  end

  defp parse_element(['~' | toks], element) do
    combinator = %Combinator.NextSiblingElements{
      selector: parse_element(toks)
    }
    (parse_element [], %{element | combinator: combinator})
  end

  # Parse Attribute

  @attribute_value_selector_types [:value,
                                   :value_contains,
                                   :value_dash,
                                   :value_includes,
                                   :value_prefix,
                                   :value_suffix]

  defp parse_attribute(['^', {:ident, attr}, ']' | toks]) do
    selector = %Attribute.AttributePrefix{attribute: List.to_string(attr)}
    {selector, toks}
  end

  defp parse_attribute([{:ident, attr}, type, {:ident, val}, ']' | toks]) when type in @attribute_value_selector_types do
    selector = attribute_value_selector(
      type,
      List.to_string(attr),
      List.to_string(val))
    {selector, toks}
  end

  defp parse_attribute([{:ident, attr}, type, {:string, val}, ']' | toks]) when type in @attribute_value_selector_types do
    selector = attribute_value_selector(
      type,
      List.to_string(attr),
      List.to_string(val))
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
    parse_pseudo_class_args(type, toks, [List.to_integer(arg)|args])
  end

  defp parse_pseudo_class_args(type, [{:ident, arg} | toks], args) do
    parse_pseudo_class_args(type, toks, [List.to_string(arg)|args])
  end

  defp parse_pseudo_class_args(type, [{:string, arg} | toks], args) do
    parse_pseudo_class_args(type, toks, [List.to_string(arg)|args])
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
    selector = parse_element(tokens)
    {[selector], toks}
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
        raise ParseError, "Pseudo class \"#{type}\" not supported"
    end
  end
end
