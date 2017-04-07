defmodule Meeseeks.Selector.CSS.ParserTest do
  use ExUnit.Case

  alias Meeseeks.Selector.InvalidSelectorError
  alias Meeseeks.Selector.CSS.{Parser, Tokenizer}
  alias Meeseeks.Selector.CSS.Parser.ParseError
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.Element

  test "start with any namespace and any tag" do
    tokens = Tokenizer.tokenize("*|*")
    selectors = [
      %Element{
        selectors: [
          %Element.Namespace{value: "*"},
          %Element.Tag{value: "*"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with namespaced tag" do
    tokens = Tokenizer.tokenize("namespace|tag.class")
    selectors = [
      %Element{
        selectors: [
          %Element.Namespace{value: "namespace"},
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with tag" do
    tokens = Tokenizer.tokenize("tag.class")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with class" do
    tokens = Tokenizer.tokenize(".class")
    selectors = [
      %Element{
        selectors: [
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with id" do
    tokens = Tokenizer.tokenize("#id.class")
    selectors = [
      %Element{
        selectors: [
          %Element.Attribute.Value {attribute: "id", value: "id"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with attribute" do
    tokens = Tokenizer.tokenize("[attr]")
    selectors = [
      %Element{
        selectors: [
          %Element.Attribute.Attribute {attribute: "attr"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "start with pseudo class" do
    tokens = Tokenizer.tokenize(":first-child")
    selectors = [
      %Element{
        selectors: [
          %Element.PseudoClass.FirstChild{}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with int arg" do
    tokens = Tokenizer.tokenize("tag:nth-child(2)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthChild{args: [2]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with ident arg" do
    tokens = Tokenizer.tokenize("tag:nth-last-child(even)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthLastChild{args: ["even"]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with string arg" do
    tokens = Tokenizer.tokenize("tag:nth-last-of-type(\"odd\")")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthLastOfType{args: ["odd"]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with full ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-of-type( +2n -3)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthOfType{args: [2, -3]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with partial a ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-child(-n -3)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthChild{args: [-1, -3]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "pseudo class with no b ab_formula arg" do
    tokens = Tokenizer.tokenize("tag:nth-child( n )")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.NthChild{args: [1, 0]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "not pseudo class" do
    tokens = Tokenizer.tokenize("tag:not(div.class)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.Not{
            args: [
              [%Element{
                  selectors: [
                    %Element.Tag{value: "div"},
                    %Element.Attribute.ValueIncludes{attribute: "class",
                                                     value: "class"}]}]]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "not pseudo class with multiple selectors" do
    tokens = Tokenizer.tokenize("tag:not(div, .class)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.Not{
            args: [
              [%Element{
                  selectors: [
                    %Element.Tag{value: "div"}]},
               %Element{
                 selectors: [
                   %Element.Attribute.ValueIncludes{attribute: "class",
                                                    value: "class"}]}]]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "not pseudo class containing selector with combinator" do
    tokens = Tokenizer.tokenize("tag:not(li > a)")
    assert_raise InvalidSelectorError, ":not doesn't allow selectors containing combinators", fn ->
      Parser.parse_elements(tokens)
    end
  end

  test "not pseudo class containing selector with not pseudo class" do
    tokens = Tokenizer.tokenize("tag:not(a:not(li))")
    assert_raise InvalidSelectorError, ":not doesn't allow selectors containing :not selectors", fn ->
      Parser.parse_elements(tokens)
    end
  end

  test "multiple pseudo classes" do
    tokens = Tokenizer.tokenize("tag:first-child:not(a)")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.PseudoClass.FirstChild{},
          %Element.PseudoClass.Not{
            args: [[%Element{ selectors: [%Element.Tag{value: "a"}]}]]}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "unknown pseudo class" do
    tokens = Tokenizer.tokenize(":nonexistent-pseudo")
    assert_raise ParseError, "Pseudo class \"nonexistent-pseudo\" not supported", fn ->
      Parser.parse_elements(tokens)
    end
  end

  test "pseudo class with invalid args" do
    tokens = Tokenizer.tokenize(":nth-child(evens)")
    assert_raise InvalidSelectorError, ":nth-child has invalid arguments", fn ->
      Parser.parse_elements(tokens)
    end
  end

  test "attribute" do
    tokens = Tokenizer.tokenize("tag[attr]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.Attribute{attribute: "attr"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute prefix" do
    tokens = Tokenizer.tokenize("tag[^att]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.AttributePrefix{attribute: "att"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute equals" do
    tokens = Tokenizer.tokenize("tag[attr=\"value\"]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.Value{attribute: "attr", value: "value"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute value contains" do
    tokens = Tokenizer.tokenize("tag[attr*=alu]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueContains{attribute: "attr", value: "alu"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute value dash" do
    tokens = Tokenizer.tokenize("tag[attr|=data]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueDash{attribute: "attr", value: "data"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute value includes" do
    tokens = Tokenizer.tokenize("tag[attr~=\"includes\"]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "attr", value: "includes"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute value prefix" do
    tokens = Tokenizer.tokenize("tag[attr^=val]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValuePrefix{attribute: "attr", value: "val"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "attribute value suffix" do
    tokens = Tokenizer.tokenize("tag[attr$=lue]")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueSuffix{attribute: "attr", value: "lue"}]}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "descendant" do
    tokens = Tokenizer.tokenize("tag.class tag#id")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}],
        combinator: %Combinator.DescendantElements{
          selector: %Element{
            selectors: [
              %Element.Tag{value: "tag"},
              %Element.Attribute.Value{attribute: "id", value: "id"}]}}}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "child" do
    tokens = Tokenizer.tokenize("tag.class > tag#id")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}],
        combinator: %Combinator.ChildElements{
          selector: %Element{
            selectors: [
              %Element.Tag{value: "tag"},
              %Element.Attribute.Value{attribute: "id", value: "id"}]}}}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "next sibling" do
    tokens = Tokenizer.tokenize("tag.class + tag#id")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}],
        combinator: %Combinator.NextSiblingElement{
          selector: %Element{
            selectors: [
              %Element.Tag{value: "tag"},
              %Element.Attribute.Value{attribute: "id", value: "id"}]}}}]
    assert Parser.parse_elements(tokens) == selectors
  end

  test "next siblings" do
    tokens = Tokenizer.tokenize("tag.class ~ tag#id")
    selectors = [
      %Element{
        selectors: [
          %Element.Tag{value: "tag"},
          %Element.Attribute.ValueIncludes{attribute: "class", value: "class"}],
        combinator: %Combinator.NextSiblingElements{
          selector: %Element{
            selectors: [
              %Element.Tag{value: "tag"},
              %Element.Attribute.Value{attribute: "id", value: "id"}]}}}]
    assert Parser.parse_elements(tokens) == selectors
  end
end
