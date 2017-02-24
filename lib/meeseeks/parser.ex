defmodule Meeseeks.Parser do
  @moduledoc false

  alias Meeseeks.{Document, TupleTree}

  @type source :: String.t | TupleTree.t
  @type error :: {:error, String.t}

  @spec parse(source) :: Document.t | error

  def parse(html_string) when is_binary(html_string) do
    case Html5ever.parse(html_string) do
      {:ok, parsed_html} ->  Document.new(parsed_html)
      {:error, error} -> {:error, error}
    end
  end

  def parse(tuple_tree) do
    Document.new(tuple_tree)
  end
end
