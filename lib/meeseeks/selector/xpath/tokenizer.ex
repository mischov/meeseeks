defmodule Meeseeks.Selector.XPath.Tokenizer do
  @moduledoc false

  def tokenize(selector) do
    selector_chars =
      selector
      |> String.trim()
      |> String.to_charlist()

    :xmerl_xpath_scan.tokens(selector_chars)
  end
end
