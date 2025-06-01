defmodule Meeseeks.Selector.CSS.TokenizerTest do
  use ExUnit.Case

  alias Meeseeks.Error
  alias Meeseeks.Selector.CSS.Tokenizer

  test "multiple selectors" do
    selector = "tag1, tag2"
    tokens = [{:ident, ~c"tag1"}, ~c",", {:ident, ~c"tag2"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with namespaced tag" do
    selector = "namespace|tag.class"
    tokens = [{:ident, ~c"namespace"}, ~c"|", {:ident, ~c"tag"}, {:class, ~c"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with tag" do
    selector = "tag.class"
    tokens = [{:ident, ~c"tag"}, {:class, ~c"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with class" do
    selector = ".class"
    tokens = [{:class, ~c"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with escaped class" do
    selector = ".\\123"
    tokens = [class: ~c"123"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with unicode class" do
    selector = ".❤"
    tokens = [class: [?❤]]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with id" do
    selector = "#id.class"
    tokens = [{:id, ~c"id"}, {:class, ~c"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with escaped id" do
    selector = "#\\123"
    tokens = [id: ~c"123"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with unicode id" do
    selector = "#❤"
    tokens = [id: [?❤]]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with attribute" do
    selector = "[attr]"
    tokens = [~c"[", {:ident, ~c"attr"}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with pseudo" do
    selector = ":first-child"
    tokens = [~c":", {:ident, ~c"first-child"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with int" do
    selector = "tag:nth-child(2)"
    tokens = [{:ident, ~c"tag"}, ~c":", {:function, ~c"nth-child"}, {:int, ~c"2"}, ~c")"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with ident" do
    selector = "tag:nth-child(even)"
    tokens = [{:ident, ~c"tag"}, ~c":", {:function, ~c"nth-child"}, {:ident, ~c"even"}, ~c")"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with string" do
    selector = "tag:nth-child(\"odd\")"
    tokens = [{:ident, ~c"tag"}, ~c":", {:function, ~c"nth-child"}, {:string, ~c"odd"}, ~c")"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with formula" do
    selector = "tag:nth-child( n+ 3)"

    tokens = [
      {:ident, ~c"tag"},
      ~c":",
      {:function, ~c"nth-child"},
      {:ab_formula, ~c"n+ 3"},
      ~c")"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo not with pseudo" do
    selector = "tag:not(:nth-child(1))"

    tokens = [
      {:ident, ~c"tag"},
      ~c":",
      {:function, ~c"not"},
      ~c":",
      {:function, ~c"nth-child"},
      {:int, ~c"1"},
      ~c")",
      ~c")"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo not with multiple" do
    selector = "tag:not(.class, #id)"

    tokens = [
      {:ident, ~c"tag"},
      ~c":",
      {:function, ~c"not"},
      {:class, ~c"class"},
      ~c",",
      {:id, ~c"id"},
      ~c")"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute prefix" do
    selector = "tag[^att]"
    tokens = [{:ident, ~c"tag"}, ~c"[", ~c"^", {:ident, ~c"att"}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals" do
    selector = "tag[attr=value]"
    tokens = [{:ident, ~c"tag"}, ~c"[", {:ident, ~c"attr"}, :value, {:ident, ~c"value"}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string" do
    selector = "tag[attr=\"value\"]"
    tokens = [{:ident, ~c"tag"}, ~c"[", {:ident, ~c"attr"}, :value, {:string, ~c"value"}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string with escaped" do
    selector = "tag[attr=\"\\~\\~\\~\"]"
    tokens = [{:ident, ~c"tag"}, ~c"[", {:ident, ~c"attr"}, :value, {:string, ~c"~~~"}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string with unicode" do
    selector = "tag[attr=\"❤\"]"
    tokens = [{:ident, ~c"tag"}, ~c"[", {:ident, ~c"attr"}, :value, {:string, [?❤]}, ~c"]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value includes" do
    selector = "tag[attr~=includes]"

    tokens = [
      {:ident, ~c"tag"},
      ~c"[",
      {:ident, ~c"attr"},
      :value_includes,
      {:ident, ~c"includes"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value dash" do
    selector = "tag[attr|=data]"

    tokens = [
      {:ident, ~c"tag"},
      ~c"[",
      {:ident, ~c"attr"},
      :value_dash,
      {:ident, ~c"data"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value prefix" do
    selector = "tag[attr^=val]"

    tokens = [
      {:ident, ~c"tag"},
      ~c"[",
      {:ident, ~c"attr"},
      :value_prefix,
      {:ident, ~c"val"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value suffix" do
    selector = "tag[attr$=lue]"

    tokens = [
      {:ident, ~c"tag"},
      ~c"[",
      {:ident, ~c"attr"},
      :value_suffix,
      {:ident, ~c"lue"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value contains" do
    selector = "tag[attr*=alu]"

    tokens = [
      {:ident, ~c"tag"},
      ~c"[",
      {:ident, ~c"attr"},
      :value_contains,
      {:ident, ~c"alu"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant" do
    selector = "tag.class tag#id"
    tokens = [{:ident, ~c"tag"}, {:class, ~c"class"}, :space, {:ident, ~c"tag"}, {:id, ~c"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant starting with n (because of ab formulas)" do
    selector = "author name"
    tokens = [{:ident, ~c"author"}, :space, {:ident, ~c"name"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "child" do
    selector = "tag.class > tag#id"
    tokens = [{:ident, ~c"tag"}, {:class, ~c"class"}, ~c">", {:ident, ~c"tag"}, {:id, ~c"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next sibling" do
    selector = "tag.class + tag#id"
    tokens = [{:ident, ~c"tag"}, {:class, ~c"class"}, ~c"+", {:ident, ~c"tag"}, {:id, ~c"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next sibling starting with n (because of ab formulas)" do
    selector = "author + name"
    tokens = [{:ident, ~c"author"}, ~c"+", {:ident, ~c"name"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next siblings" do
    selector = "tag.class ~ tag#id"
    tokens = [{:ident, ~c"tag"}, {:class, ~c"class"}, ~c"~", {:ident, ~c"tag"}, {:id, ~c"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  # Since the descendant combinator is signaled by a space, any following
  # token needs to avoid being whitespace greedy in a way that will eat
  # the space.

  test "descendant wildcard" do
    selector = "tag *"
    tokens = [{:ident, ~c"tag"}, :space, ~c"*"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant tag" do
    selector = "tag tag2"
    tokens = [{:ident, ~c"tag"}, :space, {:ident, ~c"tag2"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant id" do
    selector = "tag #id"
    tokens = [{:ident, ~c"tag"}, :space, {:id, ~c"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant class" do
    selector = "tag .class"
    tokens = [{:ident, ~c"tag"}, :space, {:class, ~c"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant attribute" do
    selector = "tag [attr=val]"

    tokens = [
      {:ident, ~c"tag"},
      :space,
      ~c"[",
      {:ident, ~c"attr"},
      :value,
      {:ident, ~c"val"},
      ~c"]"
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant pseudo" do
    selector = "tag :nth-child(1)"
    tokens = [{:ident, ~c"tag"}, :space, ~c":", {:function, ~c"nth-child"}, {:int, ~c"1"}, ~c")"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  # invalid input

  test "invalid input" do
    selector = "..."

    assert_raise Error, ~r/Type: :css_selector_tokenizer\n\n  Reason: :invalid_input/, fn ->
      Tokenizer.tokenize(selector)
    end
  end
end
