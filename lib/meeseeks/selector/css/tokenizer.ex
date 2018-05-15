defmodule Meeseeks.Selector.CSS.Tokenizer do
  @moduledoc false

  alias Meeseeks.Error

  def tokenize(selector) do
    selector_chars =
      selector
      |> String.trim()
      |> String.to_charlist()

    case :css_selector_tokenizer.string(selector_chars) do
      {:ok, tokens, _} ->
        tokens

      {:error, {_, _, leex_reason}, _} ->
        raise Error.new(:css_selector_tokenizer, :invalid_input, %{
                leex_reason: leex_reason,
                input: selector
              })
    end
  end
end
