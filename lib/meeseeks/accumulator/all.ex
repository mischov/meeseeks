defmodule Meeseeks.Accumulator.All do
  @moduledoc false

  alias Meeseeks.Accumulator.All
  alias Meeseeks.Result

  defstruct(
    values: :ordsets.new()
  )

  @type t :: %All{values: [Result.t]}
end
