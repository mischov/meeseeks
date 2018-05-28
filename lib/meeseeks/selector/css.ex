defmodule Meeseeks.Selector.CSS do
  @moduledoc false

  alias Meeseeks.Error
  alias Meeseeks.Selector.CSS.{Parser, Tokenizer}

  def compile_selectors(selectors_string) when is_binary(selectors_string) do
    selectors_string
    |> Tokenizer.tokenize()
    |> Parser.parse_elements()
    |> unwrap_single_selector()
  end

  def compile_selectors(invalid_input) do
    raise Error.new(:css_selector, :invalid_input, %{
            description: "Cannot compile selectors, input should be a string",
            input: invalid_input
          })
  end

  defp unwrap_single_selector([selector]), do: selector
  defp unwrap_single_selector(selectors), do: selectors
end
