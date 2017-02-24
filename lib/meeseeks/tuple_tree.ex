defmodule Meeseeks.TupleTree do
  @moduledoc false

  @type text :: String.t
  @type comment :: {:comment, String.t}
  @type element :: {String.t, [{String.t, String.t}], [node_t]}
  @type node_t :: text | comment | element
  @type t :: node | [node_t]
end
