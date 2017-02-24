defmodule Meeseeks.ExtractTest do
  use ExUnit.Case

  alias Meeseeks.Result

  @document Meeseeks.Parser.parse(
    """
    <html>
      <head></head>
      <body>
        <div class="main">
	 <p id="first-p">1</p>
	 <p data-id="second-p">2</p>
	 <script>3</script>
	</div>
      </body>
    </html>
    """
  )

  test "extract tag" do
    result = %Result{id: 6, document: @document}
    expected = "div"
    assert Result.tag(result) == expected
  end

  test "extract attributes" do
    result = %Result{id: 8, document: @document}
    expected = [{"id", "first-p"}]
    assert Result.attrs(result) == expected
  end

  test "extract attribute" do
    result = %Result{id: 11, document: @document}
    expected = "second-p"
    assert Result.attr(result, "data-id") == expected
  end

  test "extract text" do
    result = %Result{id: 8, document: @document}
    expected = "1"
    assert Result.text(result) == expected
  end

  test "extract text with children but without data" do
    result = %Result{id: 6, document: @document}
    expected = "1 2"
    assert Result.text(result) == expected
  end

  test "extract data" do
    result = %Result{id: 14, document: @document}
    expected = "3"
    assert Result.data(result) == expected
  end

  test "extract data with children but without text" do
    result = %Result{id: 6, document: @document}
    expected = "3"
    assert Result.data(result) == expected
  end

  test "extract tree" do
    result = %Result{id: 8, document: @document}
    expected = {"p", [{"id", "first-p"}], ["1"]}
    assert Result.tree(result) == expected
  end
end
