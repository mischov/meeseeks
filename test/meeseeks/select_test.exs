defmodule Meeseeks.SelectTest do
  use ExUnit.Case

  alias Meeseeks.{Result, Select}

  @document Meeseeks.Parser.parse(
    """
    <html>
      <head></head>
      <body>
        <div class="main">
	 <p id="first-p">1</p>
	 <p data-id="second-p">2</p>
	 <p>3</p>
         <div class="secondary">
           <p>4</p>
           <p>5</p>
         </div>
	</div>
      </body>
    </html>
    """
  )

  test "select all paragraphs" do
    selector = "div p"
    expected = [
      %Result{id: 8, document: @document},
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 19, document: @document},
      %Result{id: 22, document: @document}
    ]
    assert Select.all(@document, selector) == expected
  end

  test "select first paragraph" do
    selector = "div.main > p"
    expected = %Result{id: 8, document: @document}
    assert Select.one(@document, selector) == expected
  end

  test "select all with class 'main'" do
    selector = ".main"
    expected = [
      %Result{id: 6, document: @document}
    ]
    assert Select.all(@document, selector) == expected
  end

  test "select first with id 'first-p'" do
    selector = "#first-p"
    expected = %Result{id: 8, document: @document}
    assert Select.one(@document, selector) == expected
  end

  test "select all with data attributes" do
    selector = "*[^data-]"
    expected = [
      %Result{id: 11, document: @document}
    ]
    assert Select.all(@document, selector) == expected
  end

  test "select third paragraph" do
    selector = "p:nth-child(3)"
    expected = %Result{id: 14, document: @document}
    assert Select.one(@document, selector) == expected
  end

  test "select second-of-type that does not have [data-id=second-p]" do
    selector = "p:nth-of-type(2):not([data-id=second-p])"
    expected = %Result{id: 22, document: @document}
    assert Select.one(@document, selector) == expected
  end

  test "select all with class 'nonexistent' (no match)" do
    selector = ".nonexistent"
    expected = []
    assert Select.all(@document, selector) == expected
  end

  test "select one with class 'nonexistent' (no match)" do
    selector = "*|*.nonexistent"
    expected = nil
    assert Select.one(@document, selector) == expected
  end

  @result %Result{id: 17, document: @document}

  test "select all paragraphs from result" do
    selector = "p"
    expected = [
      %Result{id: 19, document: @document},
      %Result{id: 22, document: @document}
    ]
    assert Select.all(@result, selector) == expected
  end
end
