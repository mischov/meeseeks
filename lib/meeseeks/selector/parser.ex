defmodule Meeseeks.Selector.Parser do
  @moduledoc false

  alias Meeseeks.Selector.{Attribute, Combinator, Element, Pseudo}

  def parse_element(tokens) do
    parse_element(tokens, %Element{})
  end

  defp parse_element([], element) do
    element
  end

  defp parse_element([{namespace}, "|"|t], element) do
    parse_element(t, %{element | namespace: namespace})
  end

  defp parse_element(["*", "|"|t], element) do
    parse_element(t, %{element | namespace: "*"})
  end

  defp parse_element([{tag}|t], element) do
    parse_element(t, %{element | tag: tag})
  end

  defp parse_element(["*"|t], element) do
    parse_element(t, %{element | tag: "*"})
  end

  defp parse_element(["#", {id}|t], element) do
    attribute = %Attribute{match: :value, attribute: "id", value: id}
    parse_element(t, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element([".", {class}|t], element) do
    attribute = %Attribute{match: :class, attribute: "class", value: class}
    parse_element(t, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element(["["|t], element) do
    {attribute, t} = parse_attribute(t)
    parse_element(t, %{element | attributes: [attribute|element.attributes]})
  end

  defp parse_element([":"|t], element) do
    {pseudo, t} = parse_pseudo(t)
    parse_element(t, %{element | pseudo: pseudo})
  end

  defp parse_element([:descendant|t], element) do
    combinator = %Combinator{
      match: :descendant,
      selector: parse_element(t)
    }
    %{element | combinator: combinator}
  end

  defp parse_element([:child|t], element) do
    combinator = %Combinator{
      match: :child,
      selector: parse_element(t)
    }
    %{element | combinator: combinator}
  end

  defp parse_element([:adjacent|t], element) do
    combinator = %Combinator{
      match: :adjacent,
      selector: parse_element(t)
    }
    %{element | combinator: combinator}
  end

  defp parse_element([:sibling|t], element) do
    combinator = %Combinator{
      match: :sibling,
      selector: parse_element(t)
    }
    %{element | combinator: combinator}
  end

  defp parse_attribute(tokens) do
    parse_attribute(tokens, %Attribute{})
  end

  defp parse_attribute(["]"|t], attribute) do
    {attribute, t}
  end

  defp parse_attribute(["^", {attr}|t], attribute) do
    parse_attribute(t, %{attribute | match: :attribute_prefix, attribute: attr})
  end

  defp parse_attribute([{attr}, "=", {val}|t], attribute) do
    parse_attribute(t, %{attribute | match: :value, attribute: attr, value: val})
  end

  defp parse_attribute([{attr}, "^=", {val}|t], attribute) do
    parse_attribute(t, %{attribute | match: :value_prefix, attribute: attr, value: val})
  end

  defp parse_attribute([{attr}, "$=", {val}|t], attribute) do
    parse_attribute(t, %{attribute | match: :value_suffix, attribute: attr, value: val})
  end

  defp parse_attribute([{attr}, "*=", {val}|t], attribute) do
    parse_attribute(t, %{attribute | match: :value_contains, attribute: attr, value: val})
  end

  defp parse_attribute([{attr}|t], attribute) do
    parse_attribute(t, %{attribute | match: :attribute, attribute: attr})
  end

  defp parse_pseudo(tokens) do
    parse_pseudo(:match, tokens, %Pseudo{})
  end

  defp parse_pseudo(:match, [{match}, "("|t], pseudo) do
    parse_pseudo(:args, t, %{pseudo | match: parse_pseudo_match(match)})
  end

  defp parse_pseudo(:match, [{match}|t], pseudo) do
    {%{pseudo | match: parse_pseudo_match(match)}, t}
  end

  defp parse_pseudo(:args, [")"|t], pseudo) do
    {%{pseudo | args: Enum.reverse(pseudo.args)}, t}
  end

  defp parse_pseudo(:args, [arg|t], pseudo) do
    parsed_arg = parse_pseudo_arg(arg)
    parse_pseudo(:args, t, %{pseudo | args: [parsed_arg|pseudo.args]})
  end

  defp parse_pseudo_match(match_string) when is_binary(match_string) do
    case match_string do
      "nth-child" -> :nth_child
      "first-child" -> :first_child
      "last-child" -> :last_child
      _ -> raise "Pseudo selector \"#{match_string}\" is invalid"
    end
  end

  defp parse_pseudo_arg({arg_string}) when is_binary(arg_string) do
    String.to_integer(arg_string)
  rescue
    ArgumentError -> arg_string
  end
end
