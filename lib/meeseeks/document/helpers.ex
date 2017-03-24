defmodule Meeseeks.Document.Helpers do
  @moduledoc false

  def collapse_whitespace(string) do
    string
    |> String.replace(~r/[\s]+/, " ")
  end
end
