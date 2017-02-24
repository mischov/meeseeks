defmodule Meeseeks.Accumulator.One do
  @moduledoc false

  alias Meeseeks.Accumulator.One
  alias Meeseeks.Result

  defstruct(
    value: nil
  )

  @type t :: %One{value: Result.t | nil}
end
