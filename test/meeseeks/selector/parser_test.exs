defmodule Meeseeks.Selector.ParserTest do
  use ExUnit.Case

  alias Meeseeks.Selector.Attribute
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.Element
  alias Meeseeks.Selector.Parser
  alias Meeseeks.Selector.Pseudo

  test "start with any namespace and any tag" do
    tokens = ["*", "|", "*"]
    selector = %Element{
      namespace: "*",
      tag: "*"
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with namespaced tag" do
    tokens = [{"namespace"}, "|", {"tag"}, ".", {"class"}]
    selector = %Element{
      namespace: "namespace",
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with tag" do
    tokens = [{"tag"}, ".", {"class"}]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with class" do
    tokens = [".", {"class"}]
    selector = %Element{
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with id" do
    tokens = ["#", {"id"}, ".", {"class"}]
    selector = %Element{
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"},
	%Attribute{match: :value, attribute: "id", value: "id"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with attribute" do
    tokens = ["[", {"attr"}, "]"]
    selector = %Element{
      attributes: [
	%Attribute{match: :attribute, attribute: "attr"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "start with pseudo" do
    tokens = [":", {"first-child"}]
    selector = %Element{
      pseudo: %Pseudo{match: :first_child}
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "pseudo with args" do
    tokens = [{"tag"}, ":", {"nth-child"}, "(", {"2"}, ")"]
    selector = %Element{
      tag: "tag",
      pseudo: %Pseudo{match: :nth_child, args: [2]}
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute prefix" do
    tokens = [{"tag"}, "[", "^", {"att"}, "]"]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :attribute_prefix, attribute: "att"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute equals" do
    tokens = [{"tag"}, "[", {"attr"}, "=", {"value"}, "]"]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value, attribute: "attr", value: "value"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value prefix" do
    tokens = [{"tag"}, "[", {"attr"}, "^=", {"val"}, "]"]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_prefix, attribute: "attr", value: "val"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value suffix" do
    tokens = [{"tag"}, "[", {"attr"}, "$=", {"lue"}, "]"]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_suffix, attribute: "attr", value: "lue"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "attribute value contains" do
    tokens = [{"tag"}, "[", {"attr"}, "*=", {"alu"}, "]"]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :value_contains, attribute: "attr", value: "alu"}
      ]
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "descendant" do
    tokens = [{"tag"}, ".", {"class"}, :descendant, {"tag"}, "#", {"id"}]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ],
      combinator: %Combinator{
	match: :descendant,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}
	  ]
	}
      }
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "child" do
    tokens = [{"tag"}, ".", {"class"}, :child, {"tag"}, "#", {"id"}]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ],
      combinator: %Combinator{
	match: :child,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}
	  ]
	}
      }
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "adjacent" do
    tokens = [{"tag"}, ".", {"class"}, :adjacent, {"tag"}, "#", {"id"}]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ],
      combinator: %Combinator{
	match: :adjacent,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}
	  ]
	}
      }
    }
    assert Parser.parse_element(tokens) == selector
  end

  test "sibling" do
    tokens = [{"tag"}, ".", {"class"}, :sibling, {"tag"}, "#", {"id"}]
    selector = %Element{
      tag: "tag",
      attributes: [
	%Attribute{match: :class, attribute: "class", value: "class"}
      ],
      combinator: %Combinator{
	match: :sibling,
	selector: %Element{
	  tag: "tag",
	  attributes: [
	    %Attribute{match: :value, attribute: "id", value: "id"}
	  ]
	}
      }
    }
    assert Parser.parse_element(tokens) == selector
  end

end
