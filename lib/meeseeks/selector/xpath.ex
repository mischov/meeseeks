defmodule Meeseeks.Selector.XPath do
  @moduledoc false

  alias Meeseeks.Error
  alias Meeseeks.Selector.XPath.{Parser, Transpiler, Tokenizer}

  def compile_selectors(selectors_string) when is_binary(selectors_string) do
    selectors_string
    |> Tokenizer.tokenize()
    |> Parser.parse_expression()
    |> Transpiler.to_selectors()
    |> unwrap_single_selector()
  end

  def compile_selectors(invalid_input) do
    raise Error.new(:xpath_selector, :invalid_input, %{
            description: "Cannot compile selectors, input should be a string",
            input: invalid_input
          })
  end

  defp unwrap_single_selector([selector]), do: selector
  defp unwrap_single_selector(selectors), do: selectors
end
