defmodule Meeseeks.Accumulator.All do
  @moduledoc false

  alias Meeseeks.Accumulator.All
  alias Meeseeks.Document
  alias Meeseeks.Result

  defstruct(
    values: %{}
  )

  @type t :: %All{values: %{optional(Document.node_id) => Result.t}}
end
