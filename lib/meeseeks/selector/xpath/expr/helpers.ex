defmodule Meeseeks.Selector.XPath.Expr.Helpers do
  @moduledoc false

  alias Meeseeks.{Context, Document}

  @nodes Context.nodes_key()
  @other_nums [:NaN, :Infinity, :"-Infinity"]

  # eq_fmt

  def eq_fmt(x, y, document) when is_list(x) or is_list(y) do
    nodes_fmt(x, y, document)
  end

  def eq_fmt(x, y, document) when is_boolean(x) or is_boolean(y) do
    boolean(x, document)
  end

  def eq_fmt(x, y, document) when is_number(x) or is_number(y) do
    number(x, document)
  end

  def eq_fmt(x, y, document) when x in @other_nums or y in @other_nums do
    number(x, document)
  end

  def eq_fmt(x, _y, document) do
    string(x, document)
  end

  # cmp_fmt

  def cmp_fmt(x, y, document) when is_list(x) or is_list(y) do
    nodes_fmt(x, y, document)
  end

  def cmp_fmt(x, _y, document) do
    number(x, document)
  end

  # nodes_fmt

  defp nodes_fmt(x, _y, _document) when is_number(x) do
    x
  end

  defp nodes_fmt(x, _y, _document) when x in @other_nums do
    x
  end

  defp nodes_fmt(x, _y, _document) when is_boolean(x) do
    x
  end

  defp nodes_fmt(x, _y, _document) when is_binary(x) do
    x
  end

  defp nodes_fmt(x, y, document) when is_list(x) and is_number(y) do
    Enum.map(x, &(string(&1, document) |> number(document)))
  end

  defp nodes_fmt(x, y, document) when is_list(x) and y in @other_nums do
    Enum.map(x, &(string(&1, document) |> number(document)))
  end

  defp nodes_fmt(x, y, document) when is_list(x) and is_boolean(y) do
    boolean(x, document)
  end

  defp nodes_fmt(x, y, document) when is_list(x) and is_binary(y) do
    Enum.map(x, &string(&1, document))
  end

  defp nodes_fmt(x, y, document) when is_list(x) and is_list(y) do
    Enum.map(x, &string(&1, document))
  end

  # boolean

  def boolean(false, _document), do: false
  def boolean(true, _document), do: true
  def boolean("", _document), do: false
  def boolean([], _document), do: false
  def boolean(:NaN, _document), do: false
  def boolean(:Infinity, _document), do: true
  def boolean(:"-Infinity", _document), do: true
  def boolean(x, _document) when is_binary(x), do: true
  def boolean(x, _document) when is_integer(x), do: x != 0
  def boolean(x, _document) when is_float(x), do: x != 0.0
  def boolean(x, _document) when is_list(x), do: nodes?(x)

  # number

  def number(false, _document), do: 0
  def number(true, _document), do: 1
  def number("", _document), do: :NaN
  def number([], _document), do: :NaN
  def number(:NaN, _document), do: :NaN
  def number(:Infinity, _document), do: :Infinity
  def number(:"-Infinity", _document), do: :"-Infinity"
  def number(x, _document) when is_number(x), do: x
  def number(x, document) when is_list(x), do: string(x, document) |> number(document)

  def number(x, _document) when is_binary(x) do
    case Regex.run(~r/^\s*(\-?\d+(\.\d+)?)\s*$/, x) do
      [_, s] -> String.to_integer(s)
      [_, s, _] -> String.to_float(s)
      _ -> :NaN
    end
  end

  # string

  def string(false, _document), do: "false"
  def string(true, _document), do: "true"
  def string([], _document), do: ""
  def string(0, _document), do: "0"
  def string(0.0, _document), do: "0"
  def string(:NaN, _document), do: "NaN"
  def string(:Infinity, _document), do: "Infinity"
  def string(:"-Infinity", _document), do: "-Infinity"
  def string({_attr, value}, _document), do: value
  def string(%Document.Doctype{}, _document), do: ""
  def string(%Document.Comment{} = x, _document), do: x.content
  def string(%Document.Data{} = x, _document), do: x.content
  def string(%Document.Text{} = x, _document), do: x.content

  def string(%Document.Element{} = x, document) do
    children = Document.children(document, x.id)
    child_nodes = Document.get_nodes(document, children)

    child_nodes
    |> Enum.map(&string(&1, document))
    |> Enum.join("")
  end

  def string(x, _document) when is_binary(x), do: x
  def string(x, _document) when is_integer(x), do: Integer.to_string(x)
  def string(x, _document) when is_float(x), do: Float.to_string(x)

  def string(x, document) when is_list(x) do
    if nodes?(x) do
      [node | _] = x
      string(node, document)
    else
      raise ArgumentError, "invalid input to helper `string/2`: #{inspect(x)}"
    end
  end

  # nodes?

  def nodes?(xs) when is_list(xs), do: Enum.all?(xs, &node?/1)
  def nodes?(_), do: false

  # node?

  def node?(%Document.Comment{}), do: true
  def node?(%Document.Data{}), do: true
  def node?(%Document.Doctype{}), do: true
  def node?(%Document.Element{}), do: true
  def node?(%Document.Text{}), do: true
  # attribute
  def node?({attr, val}) when is_binary(attr) and is_binary(val), do: true
  # namespace
  def node?(ns) when is_binary(ns), do: true
  def node?(_), do: false

  # position

  def position(node, context) do
    context
    |> Map.fetch!(@nodes)
    |> Enum.find_index(fn n -> node == n end)
    |> plus_one()
  end

  # substring/2

  def substring(_s, :NaN), do: ""
  def substring(_s, :Infinity), do: ""
  def substring(s, :"-Infinity"), do: s
  def substring(s, n) when n <= 0, do: s

  def substring(s, n) do
    {_, sub} = String.split_at(s, n)
    sub
  end

  # substring/3

  def substring(_s, :NaN, _n2), do: ""
  def substring(_s, _n1, :NaN), do: ""
  def substring(_s, :Infinity, _n2), do: ""
  def substring(s, :"-Infinity", :Infinity), do: s
  def substring(s, :"-Infinity", n2), do: String.slice(s, 0, n2)

  def substring(s, n1, n2) when n1 <= 0 do
    case n2 do
      :"-Infinity" ->
        ""

      :Infinity ->
        String.slice(s, 0, String.length(s))

      _ ->
        len = n1 + n2

        if len <= 0 do
          ""
        else
          String.slice(s, 0, len)
        end
    end
  end

  def substring(s, n1, n2) do
    case n2 do
      :"-Infinity" ->
        ""

      :Infinity ->
        String.slice(s, n1, String.length(s))

      _ ->
        if n2 <= 0 do
          ""
        else
          String.slice(s, n1, n2)
        end
    end
  end

  # arithmetic

  def add(:NaN, _), do: :NaN
  def add(_, :NaN), do: :NaN
  def add(:Infinity, _), do: :Infinity
  def add(_, :Infinity), do: :Infinity
  def add(:"-Infinity", _), do: :"-Infinity"
  def add(_, :"-Infinity"), do: :"-Infinity"
  def add(n1, n2), do: n1 + n2

  def sub(:NaN, _), do: :NaN
  def sub(_, :NaN), do: :NaN
  def sub(:Infinity, _), do: :Infinity
  def sub(_, :Infinity), do: :Infinity
  def sub(:"-Infinity", _), do: :"-Infinity"
  def sub(_, :"-Infinity"), do: :"-Infinity"
  def sub(n1, n2), do: n1 - n2

  def mult(:NaN, _), do: :NaN
  def mult(_, :NaN), do: :NaN
  def mult(:Infinity, _), do: :Infinity
  def mult(_, :Infinity), do: :Infinity
  def mult(:"-Infinity", _), do: :"-Infinity"
  def mult(_, :"-Infinity"), do: :"-Infinity"
  def mult(n1, n2), do: n1 * n2

  def divd(:NaN, _), do: :NaN
  def divd(_, :NaN), do: :NaN
  def divd(:Infinity, _), do: :Infinity
  def divd(_, :Infinity), do: :Infinity
  def divd(:"-Infinity", _), do: :"-Infinity"
  def divd(_, :"-Infinity"), do: :"-Infinity"
  def divd(_, 0), do: :Infinity
  def divd(n1, n2), do: div(n1, n2)

  def mod(:NaN, _), do: :NaN
  def mod(_, :NaN), do: :NaN
  def mod(:Infinity, _), do: :Infinity
  def mod(_, :Infinity), do: :Infinity
  def mod(:"-Infinity", _), do: :"-Infinity"
  def mod(_, :"-Infinity"), do: :"-Infinity"
  def mod(_, 0), do: :Infinity
  def mod(n1, n2), do: rem(n1, n2)

  # numbers

  def round_(:NaN), do: :NaN
  def round_(:Infinity), do: :Infinity
  def round_(:"-Infinity"), do: :"-Infinity"
  def round_(n) when is_float(n), do: round(n)
  def round_(n) when is_integer(n), do: n

  def floor(:NaN), do: :NaN
  def floor(:Infinity), do: :Infinity
  def floor(:"-Infinity"), do: :"-Infinity"
  def floor(n) when is_float(n), do: Float.floor(n)
  def floor(n) when is_integer(n), do: n

  def ceiling(:NaN), do: :NaN
  def ceiling(:Infinity), do: :Infinity
  def ceiling(:"-Infinity"), do: :"-Infinity"
  def ceiling(n) when is_float(n), do: Float.ceil(n)
  def ceiling(n) when is_integer(n), do: n

  # compare

  # =
  def compare(:=, x, y), do: x == y
  # !=
  def compare(:!=, x, y), do: x != y
  # <=
  def compare(:<=, :NaN, :NaN), do: true
  def compare(:<=, :NaN, _), do: true
  def compare(:<=, _, :NaN), do: false
  def compare(:<=, :Infinity, :Infinity), do: true
  def compare(:<=, :Infinity, _), do: false
  def compare(:<=, _, :Infinity), do: true
  def compare(:<=, :"-Infinity", :"-Infinity"), do: true
  def compare(:<=, :"-Infinity", _), do: true
  def compare(:<=, _, :"-Infinity"), do: false
  def compare(:<=, x, y), do: x <= y
  # <
  def compare(:<, :NaN, :NaN), do: false
  def compare(:<, :NaN, _), do: true
  def compare(:<, _, :NaN), do: false
  def compare(:<, :Infinity, :Infinity), do: false
  def compare(:<, :Infinity, _), do: false
  def compare(:<, _, :Infinity), do: true
  def compare(:<, :"-Infinity", :"-Infinity"), do: false
  def compare(:<, :"-Infinity", _), do: true
  def compare(:<, _, :"-Infinity"), do: false
  def compare(:<, x, y), do: x < y
  # >=
  def compare(:>=, :NaN, :NaN), do: true
  def compare(:>=, :NaN, _), do: false
  def compare(:>=, _, :NaN), do: true
  def compare(:>=, :Infinity, :Infinity), do: true
  def compare(:>=, :Infinity, _), do: true
  def compare(:>=, _, :Infinity), do: false
  def compare(:>=, :"-Infinity", :"-Infinity"), do: true
  def compare(:>=, :"-Infinity", _), do: false
  def compare(:>=, _, :"-Infinity"), do: true
  def compare(:>=, x, y), do: x >= y
  # >
  def compare(:>, :NaN, :NaN), do: false
  def compare(:>, :NaN, _), do: false
  def compare(:>, _, :NaN), do: true
  def compare(:>, :Infinity, :Infinity), do: false
  def compare(:>, :Infinity, _), do: true
  def compare(:>, _, :Infinity), do: false
  def compare(:>, :"-Infinity", :"-Infinity"), do: false
  def compare(:>, :"-Infinity", _), do: false
  def compare(:>, _, :"-Infinity"), do: true
  def compare(:>, x, y), do: x > y

  # negate

  def negate(:NaN), do: :NaN
  def negate(:Infinity), do: :"-Infinity"
  def negate(:"-Infinity"), do: :Infinity
  def negate(n), do: -n

  # misc

  defp plus_one(n), do: n + 1
end
