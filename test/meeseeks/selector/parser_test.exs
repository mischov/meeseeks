defmodule Meeseeks.Selector.ParserTest do
  use ExUnit.Case

  alias Meeseeks.Selector.{Attribute,
                           Combinator,
                           Element,
                           Parser,
                           Pseudo,
                           Tokenizer}
  alias Meeseeks.Selector.Parser.ParseError

  test "start with any namespace and any tag" do
    tokens = Tokenizer.tokenize("*|*")
    selector = %Element{
      namespace: "*",
      tag: "*"}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with namespaced tag" do
    tokens = Tokenizer.tokenize("namespace|tag.class")
    selector = %Element{
      namespace: "namespace",
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with tag" do
    tokens = Tokenizer.tokenize("tag.class")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with class" do
    tokens = Tokenizer.tokenize(".class")
    selector = %Element{
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with id" do
    tokens = Tokenizer.tokenize("#id.class")
    selector = %Element{
      attributes: [
        %Attribute{match: :value, attribute: "id", value: "id"},
	%Attribute{match: :class, attribute: "class", value: "class"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with attribute" do
    tokens = Tokenizer.tokenize("[attr]")
    selector = %Element{
      attributes: [
	%Attribute{match: :attribute, attribute: "attr"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "start with pseudo" do
    tokens = Tokenizer.tokenize(":first-child")
    selector = %Element{
      pseudos: [%Pseudo{match: :first_child}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with int arg" do
    tokens = Tokenizer.tokenize("tag:nth-child(2)")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_child, args: [2]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with ident arg" do
    tokens = Tokenizer.tokenize("tag:nth-last-child(even)")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_last_child, args: ["even"]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with string arg" do
    tokens = Tokenizer.tokenize("tag:nth-last-of-type(\"odd\")")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_last_of_type, args: ["odd"]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with full ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-of-type( +2n -3)")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_of_type, args: [2, -3]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with partial a ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-child(-n -3)")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_child, args: [-1, -3]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with no b ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-child( n )")
    selector = %Element{
      tag: "tag",
      pseudos: [%Pseudo{match: :nth_child, args: [1, 0]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "not pseudo" do
    tokens = Tokenizer.tokenize("tag:not(div.class)")
    selector = %Element{
      tag: "tag",
      pseudos: [
        %Pseudo{match: :not,
                args: [
                  %Element{
                    tag: "div",
                    attributes: [
                      %Attribute{
                        attribute: "class",
                        match: :class,
                        value: "class"}]}]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "not pseudo cannot contain combinator" do
    tokens = Tokenizer.tokenize("tag:not(li > a)")
    selector = %Element{
      tag: "tag",
      pseudos: [
        %Pseudo{match: :not,
                args: [
                  %Element{
                    tag: "li",
                    combinator: %Combinator{
                      match: :child,
                      selector: %Element{tag: "a"}}}]}]}
    assert_raise ParseError, ":not does not allow selectors containing combinators", fn ->
      Parser.parse_element(tokens) == selector
    end
  end

  test "not pseudo cannot contain not pseudo" do
    tokens = Tokenizer.tokenize("tag:not(a:not(li))")
    selector = %Element{
      tag: "tag",
      pseudos: [
        %Pseudo{match: :not,
                args: [
                  %Element{
                    tag: "a",
                    pseudos: [
                      %Pseudo{match: :not,
                              args: [%Element{tag: "li"}]}]}]}]}
    assert_raise ParseError, ":not does not allow selectors that themselves contain :not", fn ->
      Parser.parse_element(tokens) == selector
    end
  end

  test "multiple pseudos" do
    tokens = Tokenizer.tokenize("tag:first-child:not(a)")
    selector = %Element{
      tag: "tag",
      pseudos: [
        %Pseudo{match: :first_child},
        %Pseudo{match: :not, args: [%Element{tag: "a"}]}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "unknown pseudo" do
    tokens = Tokenizer.tokenize(":nonexistent-pseudo")
    assert_raise ParseError, "Pseudo class \"nonexistent-pseudo\" not supported", fn ->
      Parser.parse_element(tokens)
    end
  end

  test "pseudo with invalid args" do
    tokens = Tokenizer.tokenize(":nth-child(evens)")
    assert_raise ParseError, "nth_child received invalid arguments", fn ->
      IO.inspect(Parser.parse_element(tokens))
    end
  end

  test "attribute" do
    tokens = Tokenizer.tokenize("tag[attr]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :attribute, attribute: "attr"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute prefix" do
    tokens = Tokenizer.tokenize("tag[^att]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :attribute_prefix, attribute: "att"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute equals" do
    tokens = Tokenizer.tokenize("tag[attr=\"value\"]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value, attribute: "attr", value: "value"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value includes" do
    tokens = Tokenizer.tokenize("tag[attr~=\"includes\"]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_includes, attribute: "attr", value: "includes"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value dash" do
    tokens = Tokenizer.tokenize("tag[attr|=data]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_dash, attribute: "attr", value: "data"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value prefix" do
    tokens = Tokenizer.tokenize("tag[attr^=val]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_prefix, attribute: "attr", value: "val"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value suffix" do
    tokens = Tokenizer.tokenize("tag[attr$=lue]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_suffix, attribute: "attr", value: "lue"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value contains" do
    tokens = Tokenizer.tokenize("tag[attr*=alu]")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_contains, attribute: "attr", value: "alu"}]}
    assert Parser.parse_element(tokens) == selector
  end

  test "descendant" do
    tokens = Tokenizer.tokenize("tag.class tag#id")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}],
      combinator: %Combinator{
	match: :descendant,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}]}}}
    assert Parser.parse_element(tokens) == selector
  end

  test "child" do
    tokens = Tokenizer.tokenize("tag.class > tag#id")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}],
      combinator: %Combinator{
	match: :child,
	selector: %Element{
	  tag: "tag",
	  attributes: [
            %Attribute{match: :value, attribute: "id", value: "id"}]}}}
    assert Parser.parse_element(tokens) == selector
  end

  test "next sibling" do
    tokens = Tokenizer.tokenize("tag.class + tag#id")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}],
      combinator: %Combinator{
	match: :next_sibling,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}]}}}
    assert Parser.parse_element(tokens) == selector
  end

  test "next siblings" do
    tokens = Tokenizer.tokenize("tag.class ~ tag#id")
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}],
      combinator: %Combinator{
	match: :next_siblings,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}]}}}
    assert Parser.parse_element(tokens) == selector
  end
end
