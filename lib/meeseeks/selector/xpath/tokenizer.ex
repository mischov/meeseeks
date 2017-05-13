defmodule Meeseeks.Selector.XPath.Tokenizer do
  @moduledoc false

  def tokenize(selector) do
    selector_chars = selector |> String.strip |> String.to_char_list
    :xmerl_xpath_scan.tokens(selector_chars)
  end
end
