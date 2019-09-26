defmodule Meeseeks.Document.NodeTest do
  use ExUnit.Case

  alias Meeseeks.Document
  alias Meeseeks.Document.Node

  @html """
  <!DOCTYPE html>
  <html>
   <head></head>
   <body>
     <div class="main">
          0   0.5
       <special:p id="first-p">  1</special:p>
       <script>2</script>
       <![CDATA[  3 ]]>
       <![CDATA[4   5 ]]>
     </div>
   </body>
  </html>
  """
  @document Meeseeks.Parser.parse(@html)

  # attr

  test "get attribute when node has attribute" do
    node = Document.get_node(@document, 7)
    expected = "main"
    assert Node.attr(node, "class") == expected
  end

  test "get attribute when node doesn't have attribute" do
    node = Document.get_node(@document, 2)
    expected = nil
    assert Node.attr(node, "class") == expected
  end

  test "get attribute when node doesn't have attributes" do
    node = Document.get_node(@document, 1)
    expected = nil
    assert Node.attr(node, "class") == expected
  end

  # attrs

  test "get attributes when node has attributes" do
    node = Document.get_node(@document, 7)
    expected = [{"class", "main"}]
    assert Node.attrs(node) == expected
  end

  test "get attributes when node doesn't have attributes" do
    node = Document.get_node(@document, 1)
    expected = nil
    assert Node.attrs(node) == expected
  end

  # data

  test "get data when node has data" do
    node = Document.get_node(@document, 7)
    expected = "3 4 5"
    assert Node.data(node, @document) == expected
  end

  test "get data without collapsing whitespace when node has data" do
    node = Document.get_node(@document, 7)
    expected = "3  4   5"
    assert Node.data(node, @document, collapse_whitespace: false) == expected
  end

  test "get data without trimming when node has data" do
    node = Document.get_node(@document, 7)
    expected = " 3 4 5 "
    assert Node.data(node, @document, trim: false) == expected
  end

  test "get data when node doesn't have data" do
    node = Document.get_node(@document, 1)
    expected = ""
    assert Node.data(node, @document) == expected
  end

  # html

  test "get html" do
    node = Document.get_node(@document, 2)

    expected =
      "<html><head></head>\n <body>\n   <div class=\"main\">\n        0   0.5\n     <special:p id=\"first-p\">  1</special:p>\n     <script>2</script>\n     <![CDATA[  3 ]]>\n     <![CDATA[4   5 ]]>\n   </div>\n \n\n</body></html>"

    assert Node.html(node, @document) == expected
  end

  # own_text

  test "get own text when node has text" do
    node = Document.get_node(@document, 7)
    expected = "0 0.5"
    assert Node.own_text(node, @document) == expected
  end

  test "get own text without collapsing whitespace when node has text" do
    node = Document.get_node(@document, 7)
    expected = "0   0.5"
    assert Node.own_text(node, @document, collapse_whitespace: false) == expected
  end

  test "get own text without trimming when node has text" do
    node = Document.get_node(@document, 7)
    expected = " 0 0.5 "
    assert Node.own_text(node, @document, trim: false) == expected
  end

  test "get own text when node doesn't have text" do
    node = Document.get_node(@document, 1)
    expected = ""
    assert Node.own_text(node, @document) == expected
  end

  # tag

  test "get tag when node has tag" do
    node = Document.get_node(@document, 2)
    expected = "html"
    assert Node.tag(node) == expected
  end

  test "get tag when node doesn't have tag" do
    node = Document.get_node(@document, 1)
    expected = nil
    assert Node.tag(node) == expected
  end

  # text

  test "get text when node has text" do
    node = Document.get_node(@document, 7)
    expected = "0 0.5 1"
    assert Node.text(node, @document) == expected
  end

  test "get text without collapsing whitespace when node has text" do
    node = Document.get_node(@document, 7)
    expected = "0   0.5\n        1"
    assert Node.text(node, @document, collapse_whitespace: false) == expected
  end

  test "get text without trimming when node has text" do
    node = Document.get_node(@document, 7)
    expected = " 0 0.5 1 "
    assert Node.text(node, @document, trim: false) == expected
  end

  test "get text when node doesn't have text" do
    node = Document.get_node(@document, 1)
    expected = ""
    assert Node.text(node, @document) == expected
  end

  # tree

  test "get tree" do
    node = Document.get_node(@document, 2)

    expected =
      {"html", [],
       [
         {"head", [], []},
         "\n ",
         {"body", [],
          [
            "\n   ",
            {"div", [{"class", "main"}],
             [
               "\n        0   0.5\n     ",
               {"p", [{"id", "first-p"}], ["  1"]},
               "\n     ",
               {"script", [], ["2"]},
               "\n     ",
               "  3 ",
               "\n     ",
               "4   5 ",
               "\n   "
             ]},
            "\n \n\n"
          ]}
       ]}

    assert Node.tree(node, @document) == expected
  end
end
