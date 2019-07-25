defmodule Meeseeks.Document.Helpers do
  @moduledoc false

  # collapse_whitespace

  def collapse_whitespace(string) do
    String.replace(string, ~r/[\s]+/, " ")
  end

  # html_escape

  def html_escape_attribute_value(attribute_value) do
    html_escape_chars(attribute_value, ["&", "\""])
  end

  def html_escape_text(text) do
    html_escape_chars(text, ["&", "<", ">"])
  end

  defp html_escape_chars(subject, escaped_chars) do
    matches = :binary.matches(subject, escaped_chars)

    subject
    |> do_replace(matches, &html_escape_char/1, 0)
    |> IO.iodata_to_binary()
  end

  defp do_replace(subject, [], _, n) do
    [binary_part(subject, n, byte_size(subject) - n)]
  end

  defp do_replace(subject, [{start, length} | matches], replacement, n) do
    prefix = binary_part(subject, n, start - n)
    middle = replacement.(binary_part(subject, start, length))
    [prefix, middle | do_replace(subject, matches, replacement, start + length)]
  end

  defp html_escape_char("<"), do: "&lt;"
  defp html_escape_char(">"), do: "&gt;"
  defp html_escape_char("&"), do: "&amp;"
  defp html_escape_char("\""), do: "&quot;"
  defp html_escape_char("'"), do: "&#39;"
end
