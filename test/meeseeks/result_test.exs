defmodule Meeseeks.ResultTest do
  use ExUnit.Case

  alias Meeseeks.Result

  @document Meeseeks.Parser.parse(
    """
    <html>
      <head></head>
      <body>
        <div class="main">
          0
          <p id="first-p">1</p>
          <p data-id="second-p">2</p>
          <script>3</script>
        </div>
      </body>
    </html>
    """)

  test "get result's attribute" do
    result = %Result{id: 11, document: @document}
    expected = "second-p"
    assert Result.attr(result, "data-id") == expected
  end

  test "get result's attributes" do
    result = %Result{id: 8, document: @document}
    expected = [{"id", "first-p"}]
    assert Result.attrs(result) == expected
  end

  test "get result's data" do
    result = %Result{id: 14, document: @document}
    expected = "3"
    assert Result.data(result) == expected
  end

  test "do not get result's grandchildren's data" do
    result = %Result{id: 6, document: @document}
    expected = ""
    assert Result.data(result) == expected
  end

  test "get result's html (including descendants and preserving whitespace)" do
    result = %Result{id: 6, document: @document}
    expected = "<div class=\"main\">\n      0\n      <p id=\"first-p\">1</p>\n      <p data-id=\"second-p\">2</p>\n      <script>3</script>\n    </div>"
    assert Result.html(result) == expected
  end

  test "get text of result's children only" do
    result = %Result{id: 6, document: @document}
    expected = "0"
    assert Result.own_text(result) == expected
  end

  test "get result's tag" do
    result = %Result{id: 6, document: @document}
    expected = "div"
    assert Result.tag(result) == expected
  end

  test "get result's text" do
    result = %Result{id: 8, document: @document}
    expected = "1"
    assert Result.text(result) == expected
  end

  test "get text of result's descendants without data" do
    result = %Result{id: 6, document: @document}
    expected = "0 1 2"
    assert Result.text(result) == expected
  end

  test "get tree of result and result's descendants" do
    result = %Result{id: 8, document: @document}
    expected = {"p", [{"id", "first-p"}], ["1"]}
    assert Result.tree(result) == expected
  end
end
