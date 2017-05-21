defmodule Meeseeks.Selector.XPath.ParserTest do
  use ExUnit.Case

  alias Meeseeks.Selector.{Combinator, XPath}
  alias Meeseeks.Selector.XPath.{Expr, Parser, Tokenizer}

  # abs

  test "root only" do
    tokens = Tokenizer.tokenize("/")
    assert_raise ErlangError, fn ->
      Parser.parse_expression(tokens)
    end
  end

  test "abs wildcard" do
    tokens = Tokenizer.tokenize("/*")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "*"}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  test "abs only" do
    tokens = Tokenizer.tokenize("/root")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "root"}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  test "abs abbreviated step" do
    tokens = Tokenizer.tokenize("/root/child")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "root"}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "child"}]}],
      type: :abs}

    assert Parser.parse_expression(tokens) == expression
  end

  test "abs explicit step" do
    tokens = Tokenizer.tokenize("/root/descendant::descendant")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "root"}]},
        %Expr.Step{combinator: %Combinator.Descendants{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "descendant"}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  test "abbreviated abs" do
    tokens = Tokenizer.tokenize("//*")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.DescendantsOrSelf{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "*"}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  # rel

  test "rel wildcard only" do
    tokens = Tokenizer.tokenize("*")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "*"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "rel only" do
    tokens = Tokenizer.tokenize("node")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "node"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "rel appreviated step" do
    tokens = Tokenizer.tokenize("node/child")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "node"}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "child"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "rel explicit step" do
    tokens = Tokenizer.tokenize("node/ancestor::ancestor")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "node"}]},
        %Expr.Step{combinator: %Combinator.Ancestors{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "ancestor"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # abbreviated step

  test "self node" do
    tokens = Tokenizer.tokenize("/./child")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "child"}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  test "parent node" do
    tokens = Tokenizer.tokenize("../self::parent")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Parent{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "parent"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "child" do
    tokens = Tokenizer.tokenize("./child")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "child"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "descendant or self" do
    tokens = Tokenizer.tokenize(".//descendant")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.DescendantsOrSelf{selector: nil},
                   predicates: [%Expr.NodeType{type: :node}]},
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [%Expr.NameTest{namespace: nil,
                                               tag: "descendant"}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # abbreviated axis

  test "attribute axis" do
    tokens = Tokenizer.tokenize("@*")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %XPath.Combinator.Attributes{selector: nil},
          predicates: [%XPath.Expr.AttributeNameTest{name: "*",
                                                     namespace: nil}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # node type

  test "node type" do
    tokens = Tokenizer.tokenize("/comment()")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [%Expr.NodeType{type: :comment}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  # processing instruction

  test "processing instruction" do
    tokens = Tokenizer.tokenize("/processing-instruction('xml-spreadsheet')")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Self{selector: nil},
                   predicates: [
                     %Expr.ProcessingInstruction{target: 'xml-spreadsheet'}]}],
      type: :abs}
    assert Parser.parse_expression(tokens) == expression
  end

  # union

  test "union" do
    tokens = Tokenizer.tokenize("this|that")
    expression = %Expr.Union{
      e1: %Expr.Path{
        steps: [
          %Expr.Step{combinator: %Combinator.Children{selector: nil},
                     predicates: [%Expr.NameTest{namespace: nil,
                                                 tag: "this"}]}],
        type: :rel},
      e2: %Expr.Path{
        steps: [
          %Expr.Step{combinator: %Combinator.Children{selector: nil},
                     predicates: [%Expr.NameTest{namespace: nil,
                                                 tag: "that"}]}],
        type: :rel}}
    assert Parser.parse_expression(tokens) == expression
  end

  # filter

  test "filter" do
    tokens = Tokenizer.tokenize("(this|that)[@type != 'the-other']")
    expression = %Expr.Filter{
      e: %Expr.Union{
        e1: %Expr.Path{
          steps: [
            %Expr.Step{combinator: %Combinator.Children{selector: nil},
                       predicates: [%Expr.NameTest{namespace: nil,
                                                   tag: "this"}]}],
          type: :rel},
        e2: %Expr.Path{
          steps: [
            %Expr.Step{combinator: %Combinator.Children{selector: nil},
                       predicates: [%Expr.NameTest{namespace: nil,
                                                   tag: "that"}]}],
          type: :rel}},
      predicate: %Expr.Predicate{
        e: %Expr.Comparative{
          e1: %Expr.Path{
            steps: [
              %Expr.Step{
                combinator: %XPath.Combinator.Attributes{selector: nil},
                predicates: [%Expr.AttributeNameTest{name: "type",
                                                     namespace: nil}]}],
            type: :rel},
          e2: %Expr.Literal{value: "the-other"},
          op: :!=}}}
    assert Parser.parse_expression(tokens) == expression
  end

  # predicate

  test "predicate number" do
    tokens = Tokenizer.tokenize("*[2]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{combinator: %Combinator.Children{selector: nil},
                   predicates: [
                     %Expr.NameTest{namespace: nil,
                                    tag: "*"},
                     %Expr.Predicate{
                       e: %Meeseeks.Selector.XPath.Expr.Number{value: 2}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "predicate expr" do
    tokens = Tokenizer.tokenize("*[@id = 'good']")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Comparative{
                e1: %Expr.Path{
                  steps: [
                    %Expr.Step{
                      combinator: %XPath.Combinator.Attributes{selector: nil},
                      predicates: [
                        %Expr.AttributeNameTest{name: "id",
                                                namespace: nil}]}],
                  type: :rel},
                e2: %Expr.Literal{value: "good"},
                op: :=}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # literal

  test "literal" do
    tokens = Tokenizer.tokenize("*[@id = 'good']")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Comparative{
                e1: %Expr.Path{
                  steps: [
                    %Expr.Step{
                      combinator: %XPath.Combinator.Attributes{selector: nil},
                      predicates: [
                        %Expr.AttributeNameTest{name: "id",
                                                namespace: nil}]}],
                  type: :rel},
                e2: %Expr.Literal{value: "good"},
                op: :=}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # number

  test "number" do
    tokens = Tokenizer.tokenize("*[position() = 2]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Comparative{
                e1: %Expr.Function{args: [],
                                   f: :position},
                e2: %Expr.Number{value: 2},
                op: :=}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # function

  test "function no args" do
    tokens = Tokenizer.tokenize("*[last()]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Function{args: [], f: :last}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  test "function with args" do
    tokens = Tokenizer.tokenize("*[string(./*) = '123']")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Comparative{
                e1: %Expr.Function{
                  args: [
                    %Expr.Path{
                      steps: [
                        %Expr.Step{
                          combinator: %Combinator.Self{selector: nil},
                          predicates: [%Expr.NodeType{type: :node}]},
                        %Expr.Step{
                          combinator: %Combinator.Children{selector: nil},
                          predicates: [%Expr.NameTest{namespace: nil,
                                                      tag: "*"}]}],
                      type: :rel}],
                  f: :string},
                e2: %Expr.Literal{value: "123"},
                op: :=}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # boolean

  test "boolean" do
    tokens = Tokenizer.tokenize("*[postition() = last() and @class = 'odd']")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Boolean{
                e1: %Expr.Comparative{
                  e1: %Expr.Function{
                    args: [],
                    f: :postition},
                  e2: %Expr.Function{
                    args: [],
                    f: :last},
                  op: :=},
                e2: %Expr.Comparative{
                  e1: %Expr.Path{
                    steps: [
                      %Expr.Step{
                        combinator: %XPath.Combinator.Attributes{selector: nil},
                        predicates: [%Expr.AttributeNameTest{
                                        name: "class",
                                        namespace: nil}]}],
                    type: :rel},
                  e2: %Expr.Literal{value: "odd"},
                  op: :=},
                op: :and}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # comparative

  test "comparative" do
    tokens = Tokenizer.tokenize("*[postition() <= 3]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Comparative{
                e1: %Expr.Function{
                  args: [],
                  f: :postition},
                e2: %Expr.Number{value: 3},
                op: :<=}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # arithmetic

  test "arithmetic" do
    tokens = Tokenizer.tokenize("*[last() - 1]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Arithmetic{e1: %Expr.Function{args: [],
                                                     f: :last},
                                  e2: %Expr.Number{value: 1},
                                  op: :-}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # negative

  test "negative" do
    tokens = Tokenizer.tokenize("*[-(1 - last())]")
    expression = %Expr.Path{
      steps: [
        %Expr.Step{
          combinator: %Combinator.Children{selector: nil},
          predicates: [
            %Expr.NameTest{namespace: nil,
                           tag: "*"},
            %Expr.Predicate{
              e: %Expr.Negative{
                e: %Expr.Arithmetic{
                  e1: %Expr.Number{value: 1},
                  e2: %Expr.Function{args: [],
                                     f: :last},
                  op: :-}}}]}],
      type: :rel}
    assert Parser.parse_expression(tokens) == expression
  end

  # no var_refs

  test "no var-refs" do
    tokens = Tokenizer.tokenize("*[string(.) = $val]")
    assert_raise ErlangError, fn ->
      Parser.parse_expression(tokens)
    end
  end
end
