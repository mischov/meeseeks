defmodule Meeseeks.Selector.CSS do
  @moduledoc false

  alias Meeseeks.Selector.CSS.{Parser, Tokenizer}

  def compile_selectors(selectors_string) do
    selectors_string
    |> Tokenizer.tokenize()
    |> Parser.parse_elements()
    |> unwrap_single_selector()
  end

  defp unwrap_single_selector([selector]), do: selector
  defp unwrap_single_selector(selectors), do: selectors
end
