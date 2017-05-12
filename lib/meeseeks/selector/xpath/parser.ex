defmodule Meeseeks.Selector.XPath.Parser do
  @moduledoc false

  def parse_expression(tokens) do
    case :xpath_expression_parser.parse(tokens) do
      {:ok, expression} -> expression
      error -> error
    end
  end
end
