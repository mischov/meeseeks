defmodule Meeseeks.Selector.Parser do
  @moduledoc false

  alias Meeseeks.Selector.{Attribute, Combinator, Element, Pseudo}

  defmodule ParseError do
    @moduledoc false

    defexception [:message]
  end

  # Parse Element

  def parse_element(toks) do
    parse_element(toks, %Element{})
  end

  defp parse_element([], element) do
    %{element | attributes: Enum.reverse(element.attributes),
                pseudos: Enum.reverse(element.pseudos)}
  end

  defp parse_element([{:ident, namespace}, '|' | toks], element) do
    parse_element(toks, %{element | namespace: List.to_string(namespace)})
  end

  defp parse_element(['*', '|' | toks], element) do
    parse_element(toks, %{element | namespace: "*"})
  end

  defp parse_element([{:ident, tag} | toks], element) do
    parse_element(toks, %{element | tag: List.to_string(tag)})
  end

  defp parse_element(['*' | toks], element) do
    parse_element(toks, %{element | tag: "*"})
  end

  defp parse_element([{:id, id} | toks], element) do
    attribute = %Attribute{match: :value,
                           attribute: "id",
                           value: List.to_string(id)}
    parse_element(toks, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element([{:class, class} | toks], element) do
    attribute = %Attribute{match: :class,
                           attribute: "class",
                           value: List.to_string(class)}
    parse_element(toks, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element(['[' | toks], element) do
    {attribute, toks} = parse_attribute(toks)
    parse_element(toks, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element([':' | toks], element) do
    {pseudo, toks} = parse_pseudo(toks)
    validate_pseudo_args!(pseudo)
    parse_element(toks, %{element | pseudos: [pseudo|element.pseudos]})
  end

  defp parse_element([:space | toks], element) do
    combinator = %Combinator{
      match: :descendant,
      selector: parse_element(toks)
    }
    %{element | combinator: combinator}
  end

  defp parse_element(['>' | toks], element) do
    combinator = %Combinator{
      match: :child,
      selector: parse_element(toks)
    }
    %{element | combinator: combinator}
  end

  defp parse_element(['+' | toks], element) do
    combinator = %Combinator{
      match: :next_sibling,
      selector: parse_element(toks)
    }
    %{element | combinator: combinator}
  end

  defp parse_element(['~' | toks], element) do
    combinator = %Combinator{
      match: :next_siblings,
      selector: parse_element(toks)
    }
    %{element | combinator: combinator}
  end

  # Parse Attribute

  defp parse_attribute(toks) do
    parse_attribute(toks, %Attribute{})
  end

  defp parse_attribute([']' | toks], attribute) do
    {attribute, toks}
  end

  defp parse_attribute(['^', {:ident, attr} | toks], attribute) do
    parse_attribute(toks, %{attribute |
                            match: :attribute_prefix,
                            attribute: List.to_string(attr)})
  end

  @value_matchers [:value,
                   :value_includes,
                   :value_dash,
                   :value_prefix,
                   :value_suffix,
                   :value_contains]

  defp parse_attribute([{:ident, attr}, value_matcher, {:ident, val} | toks], attribute) when value_matcher in @value_matchers do
    parse_attribute(toks, %{attribute |
                            match: value_matcher,
                            attribute: List.to_string(attr),
                            value: List.to_string(val)})
  end

  defp parse_attribute([{:ident, attr}, value_matcher, {:string, val} | toks], attribute) when value_matcher in @value_matchers do
    parse_attribute(toks, %{attribute |
                            match: value_matcher,
                            attribute: List.to_string(attr),
                            value: List.to_string(val)})
  end

  defp parse_attribute([{:ident, attr} | toks], attribute) do
    parse_attribute(toks, %{attribute |
                            match: :attribute,
                            attribute: List.to_string(attr)})
  end

  # Parse Pseudo

  defp parse_pseudo(toks) do
    parse_pseudo(toks, %Pseudo{})
  end

  defp parse_pseudo([')' | toks], pseudo) do
    {%{pseudo | args: Enum.reverse(pseudo.args)}, toks}
  end

  defp parse_pseudo([{:ident, match} | toks], %Pseudo{match: nil} = pseudo) do
    {%{pseudo | match: parse_pseudo_match(match)}, toks}
  end

  defp parse_pseudo([{:function, match} | toks], %Pseudo{match: nil} = pseudo) do
    parse_pseudo(toks, %{pseudo | match: parse_pseudo_match(match)})
  end

  defp parse_pseudo(toks, %Pseudo{match: :not} = pseudo) do
    parse_not(toks, pseudo)
  end

  defp parse_pseudo([{:int, int} | toks], pseudo) do
    parse_pseudo(toks, %{pseudo | args: [List.to_integer(int)|pseudo.args]})
  end

  defp parse_pseudo([{:ident, arg} | toks], pseudo) do
    parse_pseudo(toks, %{pseudo | args: [List.to_string(arg)|pseudo.args]})
  end

  defp parse_pseudo([{:string, arg} | toks], pseudo) do
    parse_pseudo(toks, %{pseudo | args: [List.to_string(arg)|pseudo.args]})
  end

  defp parse_pseudo([{:ab_formula, formula} | toks], pseudo) do
    formula = List.to_string(formula)
    case Regex.run(~r/\s*([\+\-])?\s*(\d+)?[nN]\s*(([\+\-])\s*(\d+))?\s*/, formula) do
      [_] ->
        parse_pseudo(toks, %{pseudo | args: [0, 1 | pseudo.args]})
      [_, a_op] ->
        a = parse_a(a_op)
        parse_pseudo(toks, %{pseudo | args: [0, a | pseudo.args]})
      [_, a_op, a_str] ->
        a = parse_a(a_op <> a_str)
        parse_pseudo(toks, %{pseudo | args: [0, a | pseudo.args]})
      [_, a_op, a_str, _, b_op, b_str] ->
        a = parse_a(a_op <> a_str)
        b = parse_b(b_op <> b_str)
        parse_pseudo(toks, %{pseudo | args: [b, a | pseudo.args]})
    end
  end

  defp parse_pseudo_match(match_chars) do
    case match_chars do
      'first-child' -> :first_child
      'first-of-type' -> :first_of_type
      'last-child' -> :last_child
      'last-of-type' -> :last_of_type
      'not' -> :not
      'nth-child' -> :nth_child
      'nth-last-child' -> :nth_last_child
      'nth-last-of-type' -> :nth_last_of_type
      'nth-of-type' -> :nth_of_type
      _ -> raise ParseError, "Pseudo class \"#{match_chars}\" not supported"
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

  defp parse_not(toks, pseudo) do
    parse_not(toks, pseudo, 0, [])
  end

  defp parse_not([')' | toks], pseudo, 0, acc) do
    tokens = Enum.reverse(acc)
    selector = parse_element(tokens)
    {%{pseudo | args: [selector]}, toks}
  end

  defp parse_not([')' | toks], pseudo, depth, acc) do
    parse_not(toks, pseudo, depth - 1, [')' | acc])
  end

  defp parse_not([{:function, _match} = tok | toks], pseudo, depth, acc) do
    parse_not(toks, pseudo, depth + 1, [tok | acc])
  end

  defp parse_not([tok | toks], pseudo, depth, acc) do
    parse_not(toks, pseudo, depth, [tok | acc])
  end

  @argless_pseudos [:first_child, :first_of_type, :last_child, :last_of_type]

  defp validate_pseudo_args!(%Pseudo{match: match, args: args}) when match in @argless_pseudos do
    unless args == [] do
      raise ParseError, "#{match} expects no arguments"
    end
  end

  defp validate_pseudo_args!(%Pseudo{match: :not, args: args}) do
    case args do
      [%Element{combinator: combinator, pseudos: pseudos}] ->
        cond do
          combinator != nil ->
            raise ParseError, ":not does not allow selectors containing combinators"

          Enum.any?(pseudos, fn(p) -> p.match == :not end) ->
            raise ParseError, ":not does not allow selectors that themselves contain :not"
          true -> nil
        end
      _ ->
        raise ParseError, ":not recieved invalid arguments"
    end
  end

  @nth_pseudos [:nth_child, :nth_last_child, :nth_last_of_type, :nth_of_type]

  defp validate_pseudo_args!(%Pseudo{match: match, args: args}) when match in @nth_pseudos do
    case args do
      ["even"] -> nil
      ["odd"] -> nil
      [n] when is_integer(n) -> nil
      [a, b] when is_integer(a) and is_integer(b) -> nil
      _ -> raise ParseError, "#{match} received invalid arguments"
    end
  end
end
