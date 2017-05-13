defmodule Meeseeks.Accumulator.All do
  @moduledoc false

  use Meeseeks.Accumulator

  alias Meeseeks.{Accumulator, Result}

  defstruct values: %{}

  def add(%Accumulator.All{values: values} = acc, document, id) do
    result = %Result{document: document, id: id}
    %{acc | values: Map.put(values, id, result)}
  end

  def return(%Accumulator.All{values: values}) do
    Map.values(values)
    |> Enum.sort(&(&1.id <= &2.id))
  end
end
