defmodule Meeseeks.Selector.TokenizerTest do
  use ExUnit.Case

  alias Meeseeks.Selector.Tokenizer

  test "start with namespaced tag" do
    selector = "namespace|tag.class"
    tokens = [{"namespace"}, "|", {"tag"}, ".", {"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with tag" do
    selector = "tag.class"
    tokens = [{"tag"}, ".", {"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with class" do
    selector = ".class"
    tokens = [".", {"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with id" do
    selector = "#id.class"
    tokens = ["#", {"id"}, ".", {"class"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with attribute" do
    selector = "[attr]"
    tokens = ["[", {"attr"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "start with pseudo" do
    selector = ":first-child"
    tokens = [":", {"first-child"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "pseudo with args" do
    selector = "tag:nth-child(2)"
    tokens = [{"tag"}, ":", {"nth-child"}, "(", {"2"}, ")"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute prefix" do
    selector = "tag[^att]"
    tokens = [{"tag"}, "[", "^", {"att"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute equals" do
    selector = "tag[attr=value]"
    tokens = [{"tag"}, "[", {"attr"}, "=", {"value"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value prefix" do
    selector = "tag[attr^=val]"
    tokens = [{"tag"}, "[", {"attr"}, "^=", {"val"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value suffix" do
    selector = "tag[attr$=lue]"
    tokens = [{"tag"}, "[", {"attr"}, "$=", {"lue"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "attribute value contains" do
    selector = "tag[attr*=alu]"
    tokens = [{"tag"}, "[", {"attr"}, "*=", {"alu"}, "]"]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "descendant" do
    selector = "tag.class tag#id"
    tokens = [{"tag"}, ".", {"class"}, :descendant, {"tag"}, "#", {"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "child" do
    selector = "tag.class > tag#id"
    tokens = [{"tag"}, ".", {"class"}, :child, {"tag"}, "#", {"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "adjacent" do
    selector = "tag.class + tag#id"
    tokens = [{"tag"}, ".", {"class"}, :next_sibling, {"tag"}, "#", {"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

  test "sibling" do
    selector = "tag.class ~ tag#id"
    tokens = [{"tag"}, ".", {"class"}, :next_siblings, {"tag"}, "#", {"id"}]
    assert Tokenizer.tokenize(selector) == tokens
  end

end
