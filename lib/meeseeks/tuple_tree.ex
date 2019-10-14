defmodule Meeseeks.TupleTree do
  @moduledoc """
  HTML documents in Elixir/Erlang have traditionally been represented by a
  tuple tree like:

  ```elixir
  {"html", [], [
    {"head", [], []},
    {"body", [], [
      {"h1", [{"id", "greeting"}], ["Hello, World!"]}]}]}
  ```

  To parse a tuple tree use `Meeseeks.parse(tuple_tree, :tuple_tree)`
  """

  @type comment :: {:comment, String.t()}
  @type doctype :: {:doctype, String.t(), String.t(), String.t()}
  @type element :: {String.t(), [{String.t(), String.t()}], [child_node_t]}
  @type processing_instruction ::
          {:pi, String.t()}
          | {:pi, String.t(), [{String.t(), String.t()}]}
          | {:pi, String.t(), String.t()}
  @type text :: String.t()
  @type child_node_t :: comment | element | processing_instruction | text
  @type root_node_t :: comment | doctype | element | processing_instruction
  @type t :: root_node_t | [root_node_t]
end
