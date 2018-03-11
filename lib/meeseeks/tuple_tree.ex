defmodule Meeseeks.TupleTree do
  @moduledoc """
  HTML documents in Elixir/Erlang have traditionally been represented by a
  tuple-tree like:

  ```elixir
  {"html", [], [
    {"head", [], []}
    {"body", [], [
      {"h1", [{"id", "greeting"}], ["Hello, World!"]}]}]}
  ```

  `:mochiweb_html` parsed HTML into this format, and the tools for selecting
  HTML used this format, so `html5ever` (the Elixir NIF) choose to output
  to this format as well.

  Meeseeks accepts tuple-trees as input, creating `Meeseeks.Document`s from
  them.
  """

  @type comment :: {:comment, String.t()}
  @type doctype :: {:doctype, String.t(), String.t(), String.t()}
  @type element :: {String.t(), [{String.t(), String.t()}], [node_t]}
  @type processing_instruction ::
          {:pi, String.t()}
          | {:pi, String.t(), [{String.t(), String.t()}]}
          | {:pi, String.t(), String.t()}
  @type text :: String.t()
  @type node_t :: comment | doctype | element | processing_instruction | text
  @type t :: node | [node_t]
end
