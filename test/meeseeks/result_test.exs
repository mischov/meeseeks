defmodule Meeseeks.ResultTest do
  use ExUnit.Case
  doctest Meeseeks.Result

  alias Meeseeks.Result

  @document Meeseeks.Parser.parse("""
            <!DOCTYPE html>
            <html>
              <head></head>
              <body>
                <div class="main">
                  0
                  <special:p id="first-p">1</special:p>
                  <p data-id="second-p" data-other-val="42">2</p>
                  <script>3</script>
                  <p><![CDATA[4]]></p>
                </div>
              </body>
            </html>
            """)

  test "get result's attribute" do
    result = %Result{id: 12, document: @document}
    expected = "second-p"

    assert Result.attr(result, "data-id") == expected
  end

  test "get result's attributes" do
    result = %Result{id: 9, document: @document}
    expected = [{"id", "first-p"}]

    assert Result.attrs(result) == expected
  end

  test "get result's data when script" do
    result = %Result{id: 15, document: @document}
    expected = "3"

    assert Result.data(result) == expected
  end

  test "get result's data when CDATA" do
    result = %Result{id: 18, document: @document}
    expected = "4"

    assert Result.data(result) == expected
  end

  test "do not get result's grandchildren's data" do
    result = %Result{id: 7, document: @document}
    expected = ""

    assert Result.data(result) == expected
  end

  test "get result's dataset" do
    result = %Result{id: 12, document: @document}
    expected = %{"id" => "second-p", "otherVal" => "42"}

    assert Result.dataset(result) == expected
  end

  test "get result's html (including descendants and preserving whitespace)" do
    result = %Result{id: 7, document: @document}

    expected =
      "<div class=\"main\">\n      0\n      <special:p id=\"first-p\">1</special:p>\n      <p data-id=\"second-p\" data-other-val=\"42\">2</p>\n      <script>3</script>\n      <p><![CDATA[4]]></p>\n    </div>"

    assert Result.html(result) == expected
  end

  test "get text of result's children only" do
    result = %Result{id: 7, document: @document}
    expected = "0"

    assert Result.own_text(result) == expected
  end

  test "get result's tag" do
    result = %Result{id: 7, document: @document}
    expected = "div"

    assert Result.tag(result) == expected
  end

  test "get result's text" do
    result = %Result{id: 9, document: @document}
    expected = "1"

    assert Result.text(result) == expected
  end

  test "get text of result's descendants without data" do
    result = %Result{id: 7, document: @document}
    expected = "0 1 2"

    assert Result.text(result) == expected
  end

  test "get tree of result and result's descendants" do
    result = %Result{id: 9, document: @document}
    expected = {"p", [{"id", "first-p"}], ["1"]}

    assert Result.tree(result) == expected
  end
end
