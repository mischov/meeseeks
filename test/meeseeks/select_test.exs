defmodule Meeseeks.SelectTest do
  use ExUnit.Case

  import Meeseeks.CSS

  alias Meeseeks.{Accumulator, Context, Result, Select}

  @document Meeseeks.Parser.parse("""
            <html>
              <head></head>
              <body>
                <div class="main">
            <p id="first-p">1</p>
            <p data-id="second-p">2</p>
            <special:p>3</special:p>
                 <div class="secondary">
                   <p>4</p>
                   <p>5</p>
                 </div>
            </div>
              </body>
            </html>
            """)

  test "select all paragraphs in divs" do
    selector = css("div p")

    expected = [
      %Result{id: 8, document: @document},
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 19, document: @document},
      %Result{id: 22, document: @document}
    ]

    assert Select.all(@document, selector, %{}) == expected
  end

  test "select first paragraph" do
    selector = css("div.main > p")
    expected = %Result{id: 8, document: @document}
    assert Select.one(@document, selector, %{}) == expected
  end

  test "select all with class 'main'" do
    selector = css(".main")
    context = Context.add_accumulator(%{}, %Accumulator.All{})
    expected = [%Result{id: 6, document: @document}]
    assert Select.select(@document, selector, context) == expected
  end

  test "select first with id 'first-p'" do
    selector = css("#first-p")
    expected = %Result{id: 8, document: @document}
    assert Select.one(@document, selector, %{}) == expected
  end

  test "select all with data attributes" do
    selector = css("*[^data-]")
    expected = [%Result{id: 11, document: @document}]
    assert Select.all(@document, selector, %{}) == expected
  end

  test "select third paragraph" do
    selector = css("p:nth-child(3)")
    context = Context.add_accumulator(%{}, %Accumulator.One{})
    expected = %Result{id: 14, document: @document}
    assert Select.select(@document, selector, context) == expected
  end

  test "select second-of-type that does not have [data-id=second-p]" do
    selector = css("p:nth-of-type(2):not([data-id=second-p])")
    expected = %Result{id: 22, document: @document}
    assert Select.one(@document, selector, %{}) == expected
  end

  test "select all with class 'nonexistent' (no match)" do
    selector = css(".nonexistent")
    expected = []
    assert Select.all(@document, selector, %{}) == expected
  end

  test "select one with class 'nonexistent' (no match)" do
    selector = css("*|*.nonexistent")
    expected = nil
    assert Select.one(@document, selector, %{}) == expected
  end

  test "select all with namespace 'special'" do
    selector = css("special|*")
    expected = [%Result{id: 14, document: @document}]
    assert Select.all(@document, selector, %{}) == expected
  end

  @result %Result{id: 17, document: @document}

  test "select all paragraphs from result" do
    selector = css("p")

    expected = [
      %Result{id: 19, document: @document},
      %Result{id: 22, document: @document}
    ]

    assert Select.all(@result, selector, %{}) == expected
  end

  test "select next sibling p of first p from result" do
    selector = css("#first-p + p")
    expected = [%Result{id: 11, document: @document}]
    assert Select.all(@document, selector, %{}) == expected
  end

  test "select next siblings of first p from result" do
    selector = css("#first-p ~ *")

    expected = [
      %Result{id: 11, document: @document},
      %Result{id: 14, document: @document},
      %Result{id: 17, document: @document}
    ]

    assert Select.all(@document, selector, %{}) == expected
  end

  test "select with string instead of selector" do
    selector = "#first-p ~ *"

    assert_raise RuntimeError, ~r/^Expected selectors/, fn ->
      Select.all(@document, selector, %{})
    end
  end

  test "select without an accumulator" do
    selector = css("#first-p ~ *")
    context = %{}

    assert_raise RuntimeError, ~r/^No accumulator/, fn ->
      Select.select(@document, selector, context)
    end
  end
end
