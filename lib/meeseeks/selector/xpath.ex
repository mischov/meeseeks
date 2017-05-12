defmodule Meeseeks.Selector.XPath do
  @moduledoc false

  alias Meeseeks.Selector.XPath.{Parser, Transpiler, Tokenizer}

  def compile_selectors(selectors_string) do
    selectors_string
    |> Tokenizer.tokenize()
    |> Parser.parse_expression()
    |> Transpiler.to_selectors()
    |> unwrap_single_selector()
  end

  defp unwrap_single_selector([selector]), do: selector
  defp unwrap_single_selector(selectors), do: selectors
end
