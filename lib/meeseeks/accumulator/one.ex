defmodule Meeseeks.Accumulator.One do
  use Meeseeks.Accumulator
  @moduledoc false

  alias Meeseeks.{Accumulator, Result}

  defstruct value: nil

  @impl true
  def add(%Accumulator.One{value: nil} = acc, document, id) do
    result = %Result{document: document, id: id}
    %{acc | value: result}
  end

  @impl true
  def complete?(%Accumulator.One{value: nil}), do: false
  def complete?(%Accumulator.One{value: _some}), do: true

  @impl true
  def return(%Accumulator.One{value: value}), do: value
end
