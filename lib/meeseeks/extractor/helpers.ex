defmodule Meeseeks.Extractor.Helpers do
  @moduledoc false

  alias Meeseeks.Document

  # child_nodes

  def child_nodes(document, node_id) do
    children = Document.children(document, node_id)
    Document.get_nodes(document, children)
  end

  # data_node?

  def data_node?(%Document.Data{}), do: true
  def data_node?(_), do: false

  # text_node?

  def text_node?(%Document.Text{}), do: true
  def text_node?(_), do: false

  # collapse_whitespace

  def collapse_whitespace(iodata) do
    :re.replace(iodata, "[\\s]+", " ", [:global, {:return, :iodata}])
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
    do_replace(subject, matches, &html_escape_char/1, 0)
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

  # ends_in_whitespace?

  # Adapted from trim_trailing in String.Break, which is found in
  # elixir/unicode/properties.ex

  @whitespace_max_size 3

  whitespace =
    List.flatten([
      Enum.map(String.to_integer("0009", 16)..String.to_integer("000D", 16), fn int ->
        <<int::utf8>>
      end),
      <<String.to_integer("0020", 16)::utf8>>,
      <<String.to_integer("0085", 16)::utf8>>,
      <<String.to_integer("00A0", 16)::utf8>>,
      <<String.to_integer("1680", 16)::utf8>>,
      Enum.map(String.to_integer("2000", 16)..String.to_integer("200A", 16), fn int ->
        <<int::utf8>>
      end),
      <<String.to_integer("2028", 16)::utf8>>,
      <<String.to_integer("2029", 16)::utf8>>,
      <<String.to_integer("202F", 16)::utf8>>,
      <<String.to_integer("205F", 16)::utf8>>,
      <<String.to_integer("3000", 16)::utf8>>
    ])

  def ends_in_whitespace?(iodata)
  def ends_in_whitespace?(l) when is_list(l), do: list_ends_in_whitespace?(l)
  def ends_in_whitespace?(b) when is_binary(b), do: bin_ends_in_whitespace?(b)

  defp list_ends_in_whitespace?([]), do: false
  defp list_ends_in_whitespace?([x]), do: ends_in_whitespace?(x)
  defp list_ends_in_whitespace?([_, x]), do: ends_in_whitespace?(x)
  defp list_ends_in_whitespace?([_, _, x]), do: ends_in_whitespace?(x)

  defp list_ends_in_whitespace?(l) do
    [x | _] = :lists.reverse(l)
    ends_in_whitespace?(x)
  end

  defp bin_ends_in_whitespace?(""), do: false

  defp bin_ends_in_whitespace?(b) do
    bin_ends_in_whitespace?(b, byte_size(b))
  end

  defp bin_ends_in_whitespace?(b, size) when size < @whitespace_max_size do
    s_bin_ends_in_whitespace?(b)
  end

  defp bin_ends_in_whitespace?(b, size) do
    b_end = binary_part(b, size, -@whitespace_max_size)
    l_bin_ends_in_whitespace?(b_end)
  end

  for cp <- whitespace do
    case byte_size(cp) do
      3 ->
        defp l_bin_ends_in_whitespace?(unquote(cp)), do: true

      2 ->
        defp l_bin_ends_in_whitespace?(<<_, unquote(cp)>>), do: true
        defp s_bin_ends_in_whitespace?(unquote(cp)), do: true

      1 ->
        defp l_bin_ends_in_whitespace?(<<_, _, unquote(cp)>>), do: true
        defp s_bin_ends_in_whitespace?(<<_, unquote(cp)>>), do: true
        defp s_bin_ends_in_whitespace?(unquote(cp)), do: true
    end
  end

  defp l_bin_ends_in_whitespace?(_), do: false
  defp s_bin_ends_in_whitespace?(_), do: false
end
