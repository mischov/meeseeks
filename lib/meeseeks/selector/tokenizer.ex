defmodule Meeseeks.Selector.Tokenizer do
  @moduledoc false

  def tokenize("") do
    []
  end

  def tokenize(" > " <> rest) do
    [:child | tokenize(rest)]
  end

  def tokenize(" + " <> rest) do
    [:next_sibling | tokenize(rest)]
  end

  def tokenize(" ~ " <> rest) do
    [:next_siblings | tokenize(rest)]
  end

  def tokenize(" " <> rest) do
    [:descendant | tokenize(rest)]
  end

  def tokenize("[" <> rest) do
    ["[" | tokenize(rest)]
  end

  def tokenize("]" <> rest) do
    ["]" | tokenize(rest)]
  end

  def tokenize("(" <> rest) do
    ["(" | tokenize(rest)]
  end

  def tokenize(")" <> rest) do
    [")" | tokenize(rest)]
  end

  def tokenize("|" <> rest) do
    ["|" | tokenize(rest)]
  end

  def tokenize("^=" <> rest) do
    ["^=" | tokenize(rest)]
  end

  def tokenize("$=" <> rest) do
    ["$=" | tokenize(rest)]
  end

  def tokenize("*=" <> rest) do
    ["*=" | tokenize(rest)]
  end

  def tokenize("=" <> rest) do
    ["=" | tokenize(rest)]
  end

  def tokenize("^" <> rest) do
    ["^" | tokenize(rest)]
  end

  def tokenize("*" <> rest) do
    ["*" | tokenize(rest)]
  end

  def tokenize("#" <> rest) do
    ["#" | tokenize(rest)]
  end

  def tokenize("." <> rest) do
    ["." | tokenize(rest)]
  end

  def tokenize(":" <> rest) do
    [":" | tokenize(rest)]
  end

  def tokenize(string) when is_binary(string) do
    cond do
      [_, ident, rest] = Regex.run(~r/([_A-Za-z0-9-\+]+)(.*)/, string) ->
        [{ident} | tokenize(rest)]
      [_, ident, rest] = Regex.run(~r/"([_A-Za-z0-9-\+\s]+)"(.*)/, string) ->
        [{ident} | tokenize(rest)]
      :else ->
        raise(ArgumentError, "Cannot tokenize: #{string}")
    end
  end
end
