defmodule Meeseeks.XPath_Test do
  use ExUnit.Case
  doctest Meeseeks.XPath

  import Meeseeks.XPath

  alias Meeseeks.{Error, Result}

  @document Meeseeks.Parser.parse("""
            <!-- Test Document -->
            <html>
              <head></head>
              <body>
                <!-- Main -->
                <div id="main">
                  <p id="first-p">1</p>
                  <p data-id="second-p">2</p>
                  <special:p class="a b">3</special:p>
                  <div class="secondary">
                    <p>4</p>
                    <p class="b c">5</p>
                  </div>
                </div>
              </body>
            </html>
            """)

  @unicode_document Meeseeks.Parser.parse("""
                    <html>
                      <head></head>
                      <body>
                        <div id="main">
                          <p>胡麻油大好き</p>
                        </div>
                      </body>
                    </html>
                    """)

  test "absolute path single segment" do
    selector = xpath("/comment()")
    expected = [%Result{id: 1, document: @document}]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "absolute path multiple segments" do
    selector = xpath("/html/head")
    expected = [%Result{id: 3, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "rel path single segment" do
    selector = xpath("head")
    expected = [%Result{id: 3, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "rel path dot single segment" do
    selector = xpath("./head")
    expected = [%Result{id: 3, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "rel path multiple segments" do
    selector = xpath("body/div")
    expected = [%Result{id: 9, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "abbrevated descendants" do
    selector = xpath("/html//div")

    expected = [
      %Result{id: 9, document: @document},
      %Result{id: 20, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "root nodes" do
    selector = xpath("/node()")

    expected = [
      %Result{id: 1, document: @document},
      %Result{id: 2, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "root elements" do
    selector = xpath("/*")
    expected = [%Result{id: 2, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "selector union" do
    selector = xpath("/html|./head")

    expected = [
      %Result{id: 2, document: @document},
      %Result{id: 3, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "nodes that are 4th child of parent" do
    selector = xpath("//node()[4]")

    expected = [
      %Result{id: 9, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "4th node" do
    selector = xpath(".[4]")
    expected = [%Result{id: 4, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "4th element" do
    selector = xpath("self::*[4]")
    expected = [%Result{id: 9, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "second child p" do
    selector = xpath("//p[2]")

    expected = [
      %Result{id: 14, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "every child p that isn't the second child" do
    selector = xpath("//p[not(position() = 2)]")

    expected = [
      %Result{id: 11, document: @document},
      %Result{id: 17, document: @document},
      %Result{id: 22, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "the second child p that isn't the second child" do
    selector = xpath("//p[not(position() = 2)][2]")
    expected = [%Result{id: 17, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "second child p interpolation" do
    p = 2
    selector = xpath("//p[#{p}]")

    expected = [
      %Result{id: 14, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "second child p concat" do
    p = 2
    selector = xpath("//p[" <> Integer.to_string(p) <> "]")

    expected = [
      %Result{id: 14, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "second child p var" do
    p = "//p[2]"
    selector = xpath(p)

    expected = [
      %Result{id: 14, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "last child p" do
    selector = xpath("//p[last()]")

    expected = [
      %Result{id: 17, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "second child p of div with id main" do
    selector = xpath("//div[@id = 'main']/p[2]")
    expected = [%Result{id: 14, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "every child node of a div" do
    selector = xpath("//div/*")

    expected = [
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 17, document: @document},
      %Result{id: 20, document: @document},
      %Result{id: 22, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "every p node" do
    selector = xpath("//p")

    expected = [
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 17, document: @document},
      %Result{id: 22, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "every p text node" do
    selector = xpath("/html//p/text()")

    expected = [
      %Result{id: 12, document: @document},
      %Result{id: 15, document: @document},
      %Result{id: 18, document: @document},
      %Result{id: 23, document: @document},
      %Result{id: 26, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "following p siblings of #first-p" do
    selector = xpath("//p[@id='first-p']/following-sibling::p")

    expected = [
      %Result{id: 14, document: @document},
      %Result{id: 17, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "first following p sibling of #first-p" do
    selector = xpath("//p[@id='first-p']/following-sibling::p[1]")
    expected = [%Result{id: 14, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "parent of the first following p sibling of #first-p" do
    selector = xpath("//p[@id='first-p']/following-sibling::p[1]/..")
    expected = [%Result{id: 9, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "every p which isn't the descentant of multiple divs" do
    selector = xpath("//p[not(ancestor::div[2])]")

    expected = [
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 17, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "the first root html node or every not second p node" do
    selector = xpath("/html[1]|//p[not(position() = 2)]")

    expected = [
      %Result{id: 2, document: @document},
      %Result{id: 11, document: @document},
      %Result{id: 17, document: @document},
      %Result{id: 22, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "elements with 'special' namespace via path" do
    selector = xpath("*[namespace::special]")
    expected = [%Result{id: 17, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "elements with 'special' namespace via namespace-uri()" do
    selector = xpath("*[namespace-uri()='special']")
    expected = [%Result{id: 17, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "has data-id attribute" do
    selector = xpath("*[@data-id]")
    expected = [%Result{id: 14, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "id is first-p" do
    selector = xpath("//*[@id = 'first-p']")
    expected = [%Result{id: 11, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "contains class b" do
    selector = xpath("//*[contains(concat(' ', normalize-space(@class), ' '), ' b ')]")

    expected = [
      %Result{id: 17, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "div contains p with text equal to '2'" do
    selector = xpath("div[p/text() = '2']")
    expected = [%Result{id: 9, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "elements with a class attribute" do
    selector = xpath("//*[@class]")

    expected = [
      %Result{id: 17, document: @document},
      %Result{id: 20, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "element has text '5'" do
    selector = xpath("//*[text() = '5']")
    expected = [%Result{id: 25, document: @document}]
    assert Meeseeks.all(@document, selector) == expected
  end

  test "elements has text > 2.5" do
    selector = xpath("//*[text() > 2.5]")

    expected = [
      %Result{id: 17, document: @document},
      %Result{id: 22, document: @document},
      %Result{id: 25, document: @document}
    ]

    assert Meeseeks.all(@document, selector) == expected
  end

  test "raise on invalid arguments" do
    selector = xpath("//*[position(this) = 2]")

    assert_raise Error, ~r/Type: :xpath_expression\n\n  Reason: :invalid_arguments/, fn ->
      Meeseeks.all(@document, selector)
    end
  end

  test "raise on unknown function" do
    selector = xpath("//*[unknown()]")

    assert_raise Error, ~r/Type: :xpath_expression\n\n  Reason: :unknown_function/, fn ->
      Meeseeks.all(@document, selector)
    end
  end

  test "raise if attempting to use id()" do
    selector = xpath("//*[id()]")

    assert_raise Error, ~r/Type: :xpath_expression\n\n  Reason: :unknown_function/, fn ->
      Meeseeks.all(@document, selector)
    end
  end

  test "raise if attempting to use lang()" do
    selector = xpath("//*[lang()]")

    assert_raise Error, ~r/Type: :xpath_expression\n\n  Reason: :unknown_function/, fn ->
      Meeseeks.all(@document, selector)
    end
  end

  test "raise if attempting to use translate()" do
    selector = xpath("//*[translate()]")

    assert_raise Error, ~r/Type: :xpath_expression\n\n  Reason: :unknown_function/, fn ->
      Meeseeks.all(@document, selector)
    end
  end

  test "selects unicode text equal to '胡麻油大好き'" do
    selector = xpath("p[text() = '胡麻油大好き']")
    expected = [%Result{id: 8, document: @unicode_document}]
    assert Meeseeks.all(@unicode_document, selector) == expected
  end

  # macro input tests

  @expected %Meeseeks.Selector.Element{
    combinator: %Meeseeks.Selector.Combinator.Children{
      selector: %Meeseeks.Selector.Element{
        combinator: nil,
        filters: nil,
        selectors: [%Meeseeks.Selector.Element.Tag{value: "*"}]
      }
    },
    filters: nil,
    selectors: []
  }

  test "can compile string literal" do
    assert xpath("*") == @expected
  end

  test "can compile interpolated with #" do
    value = "*"
    assert xpath("#{value}") == @expected
  end

  test "can compile interpolated with <>" do
    assert xpath("" <> "*") == @expected
  end

  test "can compile from var" do
    selector_string = "*"
    assert xpath(selector_string) == @expected
  end
end
