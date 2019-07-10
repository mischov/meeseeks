defmodule Meeseeks.Selector.CSS.TokenizerTest do
  use ExUnit.Case

  alias Meeseeks.Error
  alias Meeseeks.Selector.CSS.Tokenizer

  test "multiple selectors" do
    selector = "tag1, tag2"
    tokens = [{:ident, 'tag1'}, ',', {:ident, 'tag2'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with namespaced tag" do
    selector = "namespace|tag.class"
    tokens = [{:ident, 'namespace'}, '|', {:ident, 'tag'}, {:class, 'class'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with tag" do
    selector = "tag.class"
    tokens = [{:ident, 'tag'}, {:class, 'class'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with class" do
    selector = ".class"
    tokens = [{:class, 'class'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with escaped class" do
    selector = ".\\123"
    tokens = [class: '123']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with unicode class" do
    selector = ".❤"
    tokens = [class: [?❤]]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with id" do
    selector = "#id.class"
    tokens = [{:id, 'id'}, {:class, 'class'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with escaped id" do
    selector = "#\\123"
    tokens = [id: '123']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with unicode id" do
    selector = "#❤"
    tokens = [id: [?❤]]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with attribute" do
    selector = "[attr]"
    tokens = ['[', {:ident, 'attr'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with pseudo" do
    selector = ":first-child"
    tokens = [':', {:ident, 'first-child'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with int" do
    selector = "tag:nth-child(2)"
    tokens = [{:ident, 'tag'}, ':', {:function, 'nth-child'}, {:int, '2'}, ')']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with ident" do
    selector = "tag:nth-child(even)"
    tokens = [{:ident, 'tag'}, ':', {:function, 'nth-child'}, {:ident, 'even'}, ')']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with string" do
    selector = "tag:nth-child(\"odd\")"
    tokens = [{:ident, 'tag'}, ':', {:function, 'nth-child'}, {:string, 'odd'}, ')']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo function with formula" do
    selector = "tag:nth-child( n+ 3)"
    tokens = [{:ident, 'tag'}, ':', {:function, 'nth-child'}, {:ab_formula, 'n+ 3'}, ')']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo not with pseudo" do
    selector = "tag:not(:nth-child(1))"

    tokens = [
      {:ident, 'tag'},
      ':',
      {:function, 'not'},
      ':',
      {:function, 'nth-child'},
      {:int, '1'},
      ')',
      ')'
    ]

    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo not with multiple" do
    selector = "tag:not(.class, #id)"
    tokens = [{:ident, 'tag'}, ':', {:function, 'not'}, {:class, 'class'}, ',', {:id, 'id'}, ')']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute prefix" do
    selector = "tag[^att]"
    tokens = [{:ident, 'tag'}, '[', '^', {:ident, 'att'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals" do
    selector = "tag[attr=value]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value, {:ident, 'value'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string" do
    selector = "tag[attr=\"value\"]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value, {:string, 'value'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string with escaped" do
    selector = "tag[attr=\"\\~\\~\\~\"]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value, {:string, '~~~'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals string with unicode" do
    selector = "tag[attr=\"❤\"]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value, {:string, [?❤]}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value includes" do
    selector = "tag[attr~=includes]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value_includes, {:ident, 'includes'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value dash" do
    selector = "tag[attr|=data]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value_dash, {:ident, 'data'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value prefix" do
    selector = "tag[attr^=val]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value_prefix, {:ident, 'val'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value suffix" do
    selector = "tag[attr$=lue]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value_suffix, {:ident, 'lue'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value contains" do
    selector = "tag[attr*=alu]"
    tokens = [{:ident, 'tag'}, '[', {:ident, 'attr'}, :value_contains, {:ident, 'alu'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant" do
    selector = "tag.class tag#id"
    tokens = [{:ident, 'tag'}, {:class, 'class'}, :space, {:ident, 'tag'}, {:id, 'id'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant starting with n (because of ab formulas)" do
    selector = "author name"
    tokens = [{:ident, 'author'}, :space, {:ident, 'name'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "child" do
    selector = "tag.class > tag#id"
    tokens = [{:ident, 'tag'}, {:class, 'class'}, '>', {:ident, 'tag'}, {:id, 'id'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next sibling" do
    selector = "tag.class + tag#id"
    tokens = [{:ident, 'tag'}, {:class, 'class'}, '+', {:ident, 'tag'}, {:id, 'id'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next sibling starting with n (because of ab formulas)" do
    selector = "author + name"
    tokens = [{:ident, 'author'}, '+', {:ident, 'name'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "next siblings" do
    selector = "tag.class ~ tag#id"
    tokens = [{:ident, 'tag'}, {:class, 'class'}, '~', {:ident, 'tag'}, {:id, 'id'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  # Since the descendant combinator is signaled by a space, any following
  # token needs to avoid being whitespace greedy in a way that will eat
  # the space.

  test "descendant wildcard" do
    selector = "tag *"
    tokens = [{:ident, 'tag'}, :space, '*']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant tag" do
    selector = "tag tag2"
    tokens = [{:ident, 'tag'}, :space, {:ident, 'tag2'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant id" do
    selector = "tag #id"
    tokens = [{:ident, 'tag'}, :space, {:id, 'id'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant class" do
    selector = "tag .class"
    tokens = [{:ident, 'tag'}, :space, {:class, 'class'}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant attribute" do
    selector = "tag [attr=val]"
    tokens = [{:ident, 'tag'}, :space, '[', {:ident, 'attr'}, :value, {:ident, 'val'}, ']']
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant pseudo" do
    selector = "tag :nth-child(1)"
    tokens = [{:ident, 'tag'}, :space, ':', {:function, 'nth-child'}, {:int, '1'}, ')']
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
