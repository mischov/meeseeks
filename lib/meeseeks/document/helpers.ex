defmodule Meeseeks.Document.Helpers do
  @moduledoc false

  def collapse_whitespace(string) do
    String.replace(string, ~r/[\s]+/, " ")
  end
end
