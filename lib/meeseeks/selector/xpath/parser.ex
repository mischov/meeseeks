defmodule Meeseeks.Selector.XPath.Parser do
  @moduledoc false

  alias Meeseeks.Error

  def parse_expression(tokens) do
    case :xpath_expression_parser.parse(tokens) do
      {:ok, expression} ->
        expression

      {:error, data} ->
        {:error,
         Error.new(:xpath_expression_parser, :invalid_input, %{
           data: data,
           input: tokens
         })}
    end
  end
end
